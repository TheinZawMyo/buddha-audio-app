<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\TeacherResource;
use App\Services\TeacherService;
use Illuminate\Http\JsonResponse;

class TeacherController extends Controller
{
    public function index(TeacherService $teachers): JsonResponse
    {
        return response()->json([
            'data' => TeacherResource::collection($teachers->activeList())->resolve(),
        ]);
    }

    public function show(string $slug, TeacherService $teachers): JsonResponse
    {
        $teacher = $teachers->findBySlug($slug);

        abort_unless($teacher->is_active, 404);

        return response()->json([
            'data' => TeacherResource::make($teacher)->resolve(),
        ]);
    }
}
