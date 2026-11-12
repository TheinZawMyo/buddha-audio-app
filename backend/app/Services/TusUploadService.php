<?php

namespace App\Services;

use Illuminate\Contracts\Filesystem\Filesystem;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class TusUploadService
{
    /**
     * @var list<string>
     */
    private const ALLOWED_EXTENSIONS = ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'opus', 'webm'];

    /**
     * @var list<string>
     */
    private const ALLOWED_MIME_TYPES = [
        'audio/mpeg',
        'audio/mp3',
        'audio/wav',
        'audio/x-wav',
        'audio/wave',
        'audio/mp4',
        'audio/x-m4a',
        'audio/aac',
        'audio/aacp',
        'audio/ogg',
        'audio/opus',
        'audio/webm',
        'video/webm',
    ];

    public function maxBytes(): int
    {
        return (int) config('catalog.audio_max_bytes', 512000 * 1024);
    }

    /**
     * @param  array<string, string>  $metadata
     * @return array{id: string, offset: int, length: int}
     */
    public function create(int $length, array $metadata): array
    {
        if ($length < 1 || $length > $this->maxBytes()) {
            abort(413, 'The uploaded audio exceeds the maximum allowed size.');
        }

        $filename = $this->sanitizeFilename($metadata['filename'] ?? 'audio');
        $extension = strtolower(pathinfo($filename, PATHINFO_EXTENSION));

        if (! in_array($extension, self::ALLOWED_EXTENSIONS, true)) {
            abort(415, 'Unsupported audio file type.');
        }

        $mime = isset($metadata['filetype']) ? strtolower(trim($metadata['filetype'])) : null;

        if ($mime !== null && $mime !== '' && ! in_array($mime, self::ALLOWED_MIME_TYPES, true)) {
            abort(415, 'Unsupported audio MIME type.');
        }

        $id = (string) Str::uuid();
        $disk = $this->disk();

        $disk->put($this->path($id), '');
        $disk->put($this->metaPath($id), json_encode([
            'id' => $id,
            'length' => $length,
            'filename' => $filename,
            'filetype' => $mime ?: null,
            'created_at' => now()->toIso8601String(),
        ], JSON_THROW_ON_ERROR));

        return [
            'id' => $id,
            'offset' => 0,
            'length' => $length,
        ];
    }

    /**
     * @return array{offset: int, length: int, metadata: array<string, mixed>}
     */
    public function status(string $id): array
    {
        $metadata = $this->metadata($id);

        return [
            'offset' => $this->disk()->size($this->path($id)),
            'length' => (int) $metadata['length'],
            'metadata' => $metadata,
        ];
    }

    /**
     * @param  resource  $stream
     */
    public function append(string $id, int $offset, $stream, int $contentLength): int
    {
        $metadata = $this->metadata($id);
        $disk = $this->disk();
        $path = $this->path($id);
        $currentOffset = $disk->size($path);

        if ($offset !== $currentOffset) {
            abort(409, 'The upload offset does not match the current offset.');
        }

        $remaining = (int) $metadata['length'] - $currentOffset;

        if ($remaining <= 0) {
            abort(409, 'The upload is already complete.');
        }

        if ($contentLength > $remaining) {
            abort(413, 'The uploaded chunk exceeds the declared upload length.');
        }

        $target = fopen($disk->path($path), 'ab');

        if ($target === false) {
            throw new \RuntimeException('The upload file could not be opened for writing.');
        }

        try {
            $written = stream_copy_to_stream($stream, $target, $contentLength);
        } finally {
            fclose($target);
        }

        if ($written === false || $written !== $contentLength) {
            throw new \RuntimeException('The upload chunk could not be written.');
        }

        return $currentOffset + $written;
    }

    /**
     * @return array{audio_path: string, audio_original_name: string, audio_mime: string|null, audio_size: int}
     */
    public function complete(string $id): array
    {
        $metadata = $this->metadata($id);
        $disk = $this->disk();
        $path = $this->path($id);
        $size = $disk->size($path);

        if ($size !== (int) $metadata['length']) {
            abort(409, 'The upload is not complete yet.');
        }

        $extension = strtolower(pathinfo((string) $metadata['filename'], PATHINFO_EXTENSION));
        $pendingPath = 'audio/pending/'.$id.'.'.$extension;

        if (! $disk->move($path, $pendingPath)) {
            throw new \RuntimeException('The uploaded audio could not be moved into the pending library.');
        }

        $disk->delete($this->metaPath($id));

        return [
            'audio_path' => $pendingPath,
            'audio_original_name' => (string) $metadata['filename'],
            'audio_mime' => $metadata['filetype'] ?: null,
            'audio_size' => $size,
        ];
    }

    public function delete(string $id): void
    {
        $this->assertId($id);

        $this->disk()->delete([$this->path($id), $this->metaPath($id)]);
    }

    /**
     * @return array<string, string>
     */
    public function parseMetadata(?string $header): array
    {
        if ($header === null || trim($header) === '') {
            return [];
        }

        $metadata = [];

        foreach (explode(',', $header) as $pair) {
            $pair = trim($pair);

            if ($pair === '') {
                continue;
            }

            [$key, $encodedValue] = array_pad(explode(' ', $pair, 2), 2, null);

            if (! preg_match('/^[A-Za-z0-9_-]+$/', $key)) {
                continue;
            }

            $value = $encodedValue === null ? '' : base64_decode($encodedValue, true);

            $metadata[$key] = $value === false ? '' : $value;
        }

        return $metadata;
    }

    private function sanitizeFilename(string $filename): string
    {
        $filename = basename(str_replace('\\', '/', $filename));
        $filename = preg_replace('/[\x00-\x1F\x7F\/\\\\]/u', '', $filename) ?? '';
        $filename = trim($filename);

        return $filename === '' ? 'audio' : $filename;
    }

    /**
     * @return array<string, mixed>
     */
    private function metadata(string $id): array
    {
        $this->assertId($id);
        $disk = $this->disk();
        $path = $this->metaPath($id);

        if (! $disk->exists($path)) {
            abort(404);
        }

        $metadata = json_decode($disk->get($path), true);

        if (! is_array($metadata) || ! isset($metadata['length'], $metadata['filename'])) {
            abort(404);
        }

        return $metadata;
    }

    private function assertId(string $id): void
    {
        if (! preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i', $id)) {
            abort(404);
        }
    }

    private function disk(): Filesystem
    {
        return Storage::disk(config('catalog.audio_disk'));
    }

    private function path(string $id): string
    {
        return 'audio/tus/'.$id;
    }

    private function metaPath(string $id): string
    {
        return 'audio/tus/'.$id.'.json';
    }
}
