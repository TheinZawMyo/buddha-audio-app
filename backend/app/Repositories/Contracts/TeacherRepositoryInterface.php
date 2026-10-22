<?php

namespace App\Repositories\Contracts;

use App\Models\Teacher;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

interface TeacherRepositoryInterface
{
    public function paginateForAdmin(?string $search, int $perPage = 15): LengthAwarePaginator;

    /**
     * @return Collection<int, Teacher>
     */
    public function activeList(): Collection;

    /**
     * @return Collection<int, Teacher>
     */
    public function options(): Collection;

    public function count(): int;

    public function findBySlug(string $slug): Teacher;

    public function findById(string $id): Teacher;

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function create(array $attributes): Teacher;

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function update(Teacher $teacher, array $attributes): Teacher;

    public function delete(Teacher $teacher): void;
}
