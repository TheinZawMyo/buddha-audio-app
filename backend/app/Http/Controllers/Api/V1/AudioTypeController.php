<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\AudioTypeResource;
use App\Services\AudioTypeService;
use Illuminate\Http\JsonResponse;

class AudioTypeController extends Controller
{
    public function index(AudioTypeService $types): JsonResponse
    {
        return response()->json([
            'data' => AudioTypeResource::collection($types->activeList())->resolve(),
        ]);
    }
}
