<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\CatalogCacheService;
use Illuminate\Http\JsonResponse;

class TeacherController extends Controller
{
    public function index(CatalogCacheService $cache): JsonResponse
    {
        return response()->json($cache->teachers());
    }

    public function show(string $slug, CatalogCacheService $cache): JsonResponse
    {
        $payload = $cache->teacher($slug);

        abort_if($payload === null, 404);

        return response()->json($payload);
    }
}
