<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\TusUploadService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\URL;

class TusUploadController extends Controller
{
    private const TUS_VERSION = '1.0.0';

    public function __construct(private readonly TusUploadService $uploads) {}

    public function options(): Response
    {
        return response()->noContent(204)->withHeaders([
            ...$this->tusHeaders(),
            'Tus-Version' => self::TUS_VERSION,
            'Tus-Extension' => 'creation,termination',
            'Tus-Max-Size' => (string) $this->uploads->maxBytes(),
        ]);
    }

    public function create(Request $request): Response
    {
        $this->assertTusVersion($request);

        $length = $request->header('Upload-Length');

        if (! is_string($length) || ! ctype_digit($length)) {
            return $this->error(400, 'The Upload-Length header is required.');
        }

        $metadata = $this->uploads->parseMetadata($request->header('Upload-Metadata'));
        $upload = $this->uploads->create((int) $length, $metadata);

        return response()->noContent(201)->withHeaders([
            ...$this->tusHeaders(),
            'Location' => route('admin.audios.tus.head', ['upload' => $upload['id']], false),
            'Upload-Offset' => '0',
        ]);
    }

    public function head(Request $request, string $upload): Response
    {
        $this->assertTusVersion($request);

        $status = $this->uploads->status($upload);

        return response()->noContent(200)->withHeaders([
            ...$this->tusHeaders(),
            'Upload-Offset' => (string) $status['offset'],
            'Upload-Length' => (string) $status['length'],
            'Cache-Control' => 'no-store',
        ]);
    }

    public function patch(Request $request, string $upload): Response
    {
        $this->assertTusVersion($request);

        if (! str_starts_with((string) $request->header('Content-Type'), 'application/offset+octet-stream')) {
            return $this->error(415, 'Unsupported media type.');
        }

        $offset = $request->header('Upload-Offset');

        if (! is_string($offset) || ! ctype_digit($offset)) {
            return $this->error(400, 'The Upload-Offset header is required.');
        }

        $contentLength = (int) $request->header('Content-Length', 0);

        if ($contentLength <= 0) {
            return $this->error(411, 'A Content-Length header is required.');
        }

        $newOffset = $this->uploads->append(
            $upload,
            (int) $offset,
            $request->getContent(true),
            $contentLength,
        );

        return response()->noContent(204)->withHeaders([
            ...$this->tusHeaders(),
            'Upload-Offset' => (string) $newOffset,
        ]);
    }

    public function destroy(Request $request, string $upload): Response
    {
        $this->assertTusVersion($request);
        $this->uploads->delete($upload);

        return response()->noContent(204)->withHeaders($this->tusHeaders());
    }

    public function complete(string $upload): JsonResponse
    {
        $uploadData = $this->uploads->complete($upload);

        return response()->json([
            ...$uploadData,
            'playback_url' => URL::temporarySignedRoute(
                'api.v1.audio-uploads.preview',
                now()->addMinutes((int) config('catalog.playback_url_ttl', 30)),
                ['filename' => basename($uploadData['audio_path'])],
            ),
        ]);
    }

    private function assertTusVersion(Request $request): void
    {
        $version = $request->header('Tus-Resumable');

        if ($version !== null && $version !== self::TUS_VERSION) {
            abort(412, 'Unsupported Tus version.');
        }
    }

    /**
     * @return array<string, string>
     */
    private function tusHeaders(): array
    {
        return ['Tus-Resumable' => self::TUS_VERSION];
    }

    private function error(int $status, string $message): Response
    {
        return response($message, $status)->withHeaders($this->tusHeaders());
    }
}
