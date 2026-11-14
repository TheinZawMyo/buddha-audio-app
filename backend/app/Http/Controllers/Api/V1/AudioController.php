<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\IndexAudioRequest;
use App\Services\AudioService;
use App\Services\CatalogCacheService;
use Illuminate\Http\JsonResponse;

class AudioController extends Controller
{
    public function index(IndexAudioRequest $request, CatalogCacheService $cache): JsonResponse
    {
        $filters = $request->filters();
        $limit = $filters['limit'];
        unset($filters['limit']);

        return response()->json($cache->audioIndex($filters, $limit));
    }

    public function show(string $slug, CatalogCacheService $cache): JsonResponse
    {
        return response()->json($cache->audio($slug));
    }

    public function playbackUrl(string $slug, AudioService $audios): JsonResponse
    {
        $audio = $audios->findPublishedBySlug($slug);

        if (! $audio->hasPlayableAsset()) {
            return response()->json([
                'message' => 'Playback is not available for this audio.',
            ], 404);
        }

        return response()->json([
            'data' => [
                'playback_url' => $audio->playback_url,
            ],
        ]);
    }
}
