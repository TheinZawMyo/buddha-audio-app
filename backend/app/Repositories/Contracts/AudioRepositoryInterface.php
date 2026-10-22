<?php

namespace App\Repositories\Contracts;

use App\Models\Audio;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Contracts\Pagination\CursorPaginator;
use Illuminate\Database\Eloquent\Collection;

interface AudioRepositoryInterface
{
    /**
     * @param  array{query?: string|null, teacher?: string|null, category?: string|null, type?: string|null, status?: string|null, cursor?: string|null}  $filters
     */
    public function publicPaginate(array $filters, int $limit): CursorPaginator;

    /**
     * @param  array{query?: string|null, teacher?: string|null, category?: string|null, type?: string|null}  $filters
     */
    public function publicCount(array $filters): int;

    public function findPublishedBySlug(string $slug): Audio;

    /**
     * @return Collection<int, Audio>
     */
    public function latestPublished(int $limit): Collection;

    /**
     * @param  array{query?: string|null, status?: string|null, teacher?: string|null}  $filters
     */
    public function paginateForAdmin(array $filters, int $perPage = 15): LengthAwarePaginator;

    public function findById(string $id): Audio;

    /**
     * @param  array<string, mixed>  $attributes
     * @param  array<int, string>  $categoryIds
     */
    public function create(array $attributes, array $categoryIds): Audio;

    /**
     * @param  array<string, mixed>  $attributes
     * @param  array<int, string>  $categoryIds
     */
    public function update(Audio $audio, array $attributes, array $categoryIds): Audio;

    public function delete(Audio $audio): void;

    /**
     * @return array<string, int>
     */
    public function countsByStatus(): array;

    /**
     * @return Collection<int, Audio>
     */
    public function recent(int $limit): Collection;
}
