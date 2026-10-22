<?php

namespace App\Services;

use App\Models\Audio;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

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

    public function stream(Audio $audio): BinaryFileResponse
    {
        $disk = Storage::disk(config('catalog.audio_disk'));

        if (! filled($audio->audio_path) || ! $disk->exists($audio->audio_path)) {
            throw new HttpResponseException(response()->json([
                'message' => 'The audio file is not available.',
            ], 404));
        }

        return response()->file($disk->path($audio->audio_path), [
            'Content-Type' => $audio->audio_mime ?: 'application/octet-stream',
            'Content-Disposition' => 'inline; filename="'.$audio->slug.'.'.pathinfo($audio->audio_path, PATHINFO_EXTENSION).'"',
            'Cache-Control' => 'private, max-age=0, must-revalidate',
        ]);
    }
}
