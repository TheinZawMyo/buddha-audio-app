<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\MediaService;
use Symfony\Component\HttpFoundation\Response;

class MediaImageController extends Controller
{
    public function __invoke(string $directory, string $filename, MediaService $media): Response
    {
        return $media->serveMedia($directory, $filename);
    }
}
