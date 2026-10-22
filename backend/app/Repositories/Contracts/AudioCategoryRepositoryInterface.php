<?php

namespace App\Repositories\Contracts;

use App\Models\AudioCategory;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

interface AudioCategoryRepositoryInterface
{
    public function paginateForAdmin(?string $search, int $perPage = 15): LengthAwarePaginator;

    /**
     * @return Collection<int, AudioCategory>
     */
    public function activeList(): Collection;

    /**
     * @return Collection<int, AudioCategory>
     */
    public function options(): Collection;

    public function count(): int;

    public function findBySlug(string $slug): AudioCategory;

    public function findById(string $id): AudioCategory;

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function create(array $attributes): AudioCategory;

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function update(AudioCategory $category, array $attributes): AudioCategory;

    public function delete(AudioCategory $category): void;
}
