<?php

namespace App\Repositories\Contracts;

use App\Models\AudioType;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

interface AudioTypeRepositoryInterface
{
    public function paginateForAdmin(?string $search, int $perPage = 15): LengthAwarePaginator;

    /**
     * @return Collection<int, AudioType>
     */
    public function activeList(): Collection;

    /**
     * @return Collection<int, AudioType>
     */
    public function options(): Collection;

    public function count(): int;

    public function findBySlug(string $slug): AudioType;

    public function findById(string $id): AudioType;

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function create(array $attributes): AudioType;

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function update(AudioType $type, array $attributes): AudioType;

    public function delete(AudioType $type): void;
}
