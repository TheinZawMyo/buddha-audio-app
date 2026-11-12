<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\AudioStatus;
use App\Http\Controllers\Controller;
use App\Models\Audio;
use App\Services\MediaService;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\Response;

class AudioStreamController extends Controller
{
    public function previewUpload(string $filename, MediaService $media): BinaryFileResponse
    {
        return $media->previewAudioSelection($filename);
    }

    public function __invoke(Audio $audio, MediaService $media): Response
    {
        abort_unless($audio->status === AudioStatus::Published, 404);

        return $media->stream($audio);
    }
}
