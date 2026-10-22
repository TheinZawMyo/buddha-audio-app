<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\AudioCategoryResource;
use App\Http\Resources\Api\V1\AudioResource;
use App\Http\Resources\Api\V1\AudioTypeResource;
use App\Http\Resources\Api\V1\TeacherResource;
use App\Services\HomeService;
use Illuminate\Http\JsonResponse;

class HomeController extends Controller
{
    public function __invoke(HomeService $home): JsonResponse
    {
        $content = $home->build();

        return response()->json([
            'data' => [
                'featured' => AudioResource::collection($content['featured'])->resolve(),
                'latest' => AudioResource::collection($content['latest'])->resolve(),
                'teachers' => TeacherResource::collection($content['teachers'])->resolve(),
                'categories' => AudioCategoryResource::collection($content['categories'])->resolve(),
                'audio_types' => AudioTypeResource::collection($content['types'])->resolve(),
            ],
            'meta' => [
                'generated_at' => now()->toIso8601String(),
            ],
        ]);
    }
}
