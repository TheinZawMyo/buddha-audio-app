<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\AudioCategoryResource;
use App\Services\AudioCategoryService;
use Illuminate\Http\JsonResponse;

class AudioCategoryController extends Controller
{
    public function index(AudioCategoryService $categories): JsonResponse
    {
        return response()->json([
            'data' => AudioCategoryResource::collection($categories->activeList())->resolve(),
        ]);
    }
}
