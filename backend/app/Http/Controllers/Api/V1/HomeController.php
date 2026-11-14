<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\CatalogCacheService;
use Illuminate\Http\JsonResponse;

class HomeController extends Controller
{
    public function __invoke(CatalogCacheService $cache): JsonResponse
    {
        return response()->json([
            'data' => $cache->home(),
            'meta' => [
                'generated_at' => now()->toIso8601String(),
            ],
        ]);
    }
}
