<?php

namespace App\Services;

use App\Repositories\Contracts\AudioCategoryRepositoryInterface;
use App\Repositories\Contracts\AudioRepositoryInterface;
use App\Repositories\Contracts\AudioTypeRepositoryInterface;
use App\Repositories\Contracts\TeacherRepositoryInterface;

class DashboardService
{
    public function __construct(
        private readonly AudioRepositoryInterface $audios,
        private readonly TeacherRepositoryInterface $teachers,
        private readonly AudioCategoryRepositoryInterface $categories,
        private readonly AudioTypeRepositoryInterface $types,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function summary(): array
    {
        return [
            'statusCounts' => $this->audios->countsByStatus(),
            'teacherCount' => $this->teachers->count(),
            'categoryCount' => $this->categories->count(),
            'typeCount' => $this->types->count(),
            'recentAudios' => $this->audios->recent(5),
        ];
    }
}
