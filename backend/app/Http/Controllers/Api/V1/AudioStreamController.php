<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\AudioStatus;
use App\Http\Controllers\Controller;
use App\Models\Audio;
use App\Services\MediaService;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class AudioStreamController extends Controller
{
    public function __invoke(Audio $audio, MediaService $media): BinaryFileResponse
    {
        abort_unless($audio->status === AudioStatus::Published, 404);

        return $media->stream($audio);
    }
}
