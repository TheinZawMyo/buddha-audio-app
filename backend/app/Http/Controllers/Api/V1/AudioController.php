<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\IndexAudioRequest;
use App\Http\Resources\Api\V1\AudioResource;
use App\Services\AudioService;
use Illuminate\Http\JsonResponse;

class AudioController extends Controller
{
    public function index(IndexAudioRequest $request, AudioService $audios): JsonResponse
    {
        $filters = $request->filters();
        $limit = $filters['limit'];
        unset($filters['limit']);

        $result = $audios->publicList($filters, $limit);

        return response()->json([
            'data' => AudioResource::collection($result['audios']->items())->resolve(),
            'meta' => [
                'pagination' => [
                    'next_cursor' => $result['audios']->nextCursor()?->encode(),
                    'has_more' => $result['audios']->hasMorePages(),
                    'total' => $result['total'],
                ],
            ],
        ]);
    }

    public function show(string $slug, AudioService $audios): JsonResponse
    {
        $audio = $audios->findPublishedBySlug($slug);

        return response()->json([
            'data' => AudioResource::make($audio)->resolve(),
        ]);
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
