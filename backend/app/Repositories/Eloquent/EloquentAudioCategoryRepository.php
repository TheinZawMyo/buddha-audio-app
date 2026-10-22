<?php

namespace App\Repositories\Eloquent;

use App\Models\AudioCategory;
use App\Repositories\Contracts\AudioCategoryRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class EloquentAudioCategoryRepository implements AudioCategoryRepositoryInterface
{
    public function paginateForAdmin(?string $search, int $perPage = 15): LengthAwarePaginator
    {
        return AudioCategory::query()
            ->withCount('audios')
            ->when($search, function ($query, string $search): void {
                $query->where(function ($query) use ($search): void {
                    $query->where('name', 'like', "%{$search}%")
                        ->orWhere('slug', 'like', "%{$search}%");
                });
            })
            ->ordered()
            ->paginate($perPage)
            ->withQueryString();
    }

    /**
     * @return Collection<int, AudioCategory>
     */
    public function activeList(): Collection
    {
        return AudioCategory::query()->active()->ordered()->get();
    }

    /**
     * @return Collection<int, AudioCategory>
     */
    public function options(): Collection
    {
        return AudioCategory::query()->active()->ordered()->get();
    }

    public function count(): int
    {
        return AudioCategory::query()->count();
    }

    public function findBySlug(string $slug): AudioCategory
    {
        return AudioCategory::query()->where('slug', $slug)->firstOrFail();
    }

    public function findById(string $id): AudioCategory
    {
        return AudioCategory::query()->findOrFail($id);
    }

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function create(array $attributes): AudioCategory
    {
        return AudioCategory::query()->create($attributes);
    }

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function update(AudioCategory $category, array $attributes): AudioCategory
    {
        $category->fill($attributes)->save();

        return $category->refresh();
    }

    public function delete(AudioCategory $category): void
    {
        $category->delete();
    }
}
