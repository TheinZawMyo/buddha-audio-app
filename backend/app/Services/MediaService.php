<?php

namespace App\Services;

use App\Models\Audio;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\Response;

class MediaService
{
    /**
     * @return array{audio_path: string, audio_original_name: string, audio_mime: string|null, audio_size: int}
     */
    public function storeAudio(UploadedFile $file): array
    {
        return [
            'audio_path' => $file->store('audio', config('catalog.audio_disk')),
            'audio_original_name' => $file->getClientOriginalName(),
            'audio_mime' => $file->getMimeType(),
            'audio_size' => $file->getSize(),
        ];
    }

    /**
     * @return array{audio_path: string, audio_original_name: string, audio_mime: string|null, audio_size: int}
     */
    public function storeAudioForSelection(UploadedFile $file): array
    {
        return [
            'audio_path' => $file->store('audio/pending', config('catalog.audio_disk')),
            'audio_original_name' => $file->getClientOriginalName(),
            'audio_mime' => $file->getMimeType(),
            'audio_size' => $file->getSize(),
        ];
    }

    /**
     * @return array{audio_path: string, audio_original_name: string, audio_mime: string|null, audio_size: int, external_playback_url: null}
     */
    public function finalizeAudioSelection(string $path, string $originalName): array
    {
        if (
            ! preg_match('/^audio\/pending\/[A-Za-z0-9._-]+$/D', $path)
            || basename($path) === '.'
            || basename($path) === '..'
        ) {
            abort(422, 'The selected audio upload is invalid.');
        }

        $disk = Storage::disk(config('catalog.audio_disk'));
        if (! $disk->exists($path)) {
            abort(422, 'The selected audio upload is no longer available. Please select it again.');
        }

        $finalPath = 'audio/'.basename($path);
        if (! $disk->move($path, $finalPath)) {
            throw new \RuntimeException('The selected audio upload could not be moved into the audio library.');
        }

        return [
            'audio_path' => $finalPath,
            'audio_original_name' => basename($originalName),
            'audio_mime' => $disk->mimeType($finalPath),
            'audio_size' => $disk->size($finalPath),
            'external_playback_url' => null,
        ];
    }

    public function discardAudioSelection(string $filename): void
    {
        if (
            basename($filename) !== $filename
            || in_array($filename, ['.', '..'], true)
        ) {
            abort(404);
        }

        Storage::disk(config('catalog.audio_disk'))->delete('audio/pending/'.$filename);
    }

    public function previewAudioSelection(string $filename): BinaryFileResponse
    {
        if (
            basename($filename) !== $filename
            || in_array($filename, ['.', '..'], true)
        ) {
            abort(404);
        }

        $disk = Storage::disk(config('catalog.audio_disk'));
        $path = 'audio/pending/'.$filename;

        if (! $disk->exists($path)) {
            abort(404);
        }

        return response()->file($disk->path($path), [
            'Content-Type' => $disk->mimeType($path) ?: 'application/octet-stream',
            'Content-Disposition' => 'inline; filename="'.str_replace('"', '', $filename).'"',
            'Cache-Control' => 'private, max-age=0, must-revalidate',
        ]);
    }

    public function storeCover(UploadedFile $file): string
    {
        return $this->storeImage($file, 'covers');
    }

    public function storeImage(UploadedFile $file, string $directory): string
    {
        return $file->store($directory, config('catalog.cover_disk'));
    }

    public function deleteImage(?string $path): void
    {
        $this->deleteCover($path);
    }

    public function deleteAudio(?string $path): void
    {
        if (filled($path)) {
            Storage::disk(config('catalog.audio_disk'))->delete($path);
        }
    }

    public function deleteCover(?string $path): void
    {
        if (filled($path)) {
            Storage::disk(config('catalog.cover_disk'))->delete($path);
        }
    }

    public function stream(Audio $audio): Response
    {
        $diskName = config('catalog.audio_disk');
        $disk = Storage::disk($diskName);

        if (! filled($audio->audio_path) || ! $disk->exists($audio->audio_path)) {
            throw new HttpResponseException(response()->json([
                'message' => 'The audio file is not available.',
            ], 404));
        }

        return $this->fileResponse($diskName, $audio->audio_path, [
            'Content-Type' => $audio->audio_mime ?: 'application/octet-stream',
            'Content-Disposition' => 'inline; filename="'.$audio->slug.'.'.pathinfo($audio->audio_path, PATHINFO_EXTENSION).'"',
            'Cache-Control' => 'private, max-age=0, must-revalidate',
        ]);
    }

    public function serveMedia(string $directory, string $filename): Response
    {
        if (
            ! in_array($directory, ['covers', 'teachers', 'audio'], true)
            || basename($filename) !== $filename
            || in_array($filename, ['.', '..'], true)
        ) {
            abort(404);
        }

        $diskName = $directory === 'audio'
            ? config('catalog.audio_disk')
            : config('catalog.cover_disk');
        $disk = Storage::disk($diskName);
        $path = $directory.'/'.$filename;

        if (! $disk->exists($path)) {
            abort(404);
        }

        return $this->fileResponse($diskName, $path, [
            'Content-Type' => $disk->mimeType($path) ?: 'application/octet-stream',
            'Cache-Control' => 'public, max-age=3600',
        ]);
    }

    /**
     * @param  array<string, string>  $headers
     */
    private function fileResponse(string $diskName, string $path, array $headers): Response
    {
        if (
            config('catalog.nginx_media.enabled')
            && config('filesystems.disks.'.$diskName.'.driver') === 'local'
        ) {
            $segments = explode('/', trim($path, '/'));
            if (in_array('.', $segments, true) || in_array('..', $segments, true)) {
                abort(404);
            }

            $prefix = '/'.trim((string) config('catalog.nginx_media.internal_prefix'), '/');
            $encodedPath = implode('/', array_map('rawurlencode', $segments));

            return response('', 200, [
                ...$headers,
                'X-Accel-Redirect' => $prefix.'/'.$encodedPath,
            ]);
        }

        $disk = Storage::disk($diskName);

        return response()->file($disk->path($path), $headers);
    }
}
