<?php

namespace App\Repositories\Eloquent;

use App\Models\AudioType;
use App\Repositories\Contracts\AudioTypeRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class EloquentAudioTypeRepository implements AudioTypeRepositoryInterface
{
    public function paginateForAdmin(?string $search, int $perPage = 15): LengthAwarePaginator
    {
        return AudioType::query()
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
     * @return Collection<int, AudioType>
     */
    public function activeList(): Collection
    {
        return AudioType::query()->active()->ordered()->get();
    }

    /**
     * @return Collection<int, AudioType>
     */
    public function options(): Collection
    {
        return AudioType::query()->active()->ordered()->get();
    }

    public function count(): int
    {
        return AudioType::query()->count();
    }

    public function findBySlug(string $slug): AudioType
    {
        return AudioType::query()->where('slug', $slug)->firstOrFail();
    }

    public function findById(string $id): AudioType
    {
        return AudioType::query()->findOrFail($id);
    }

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function create(array $attributes): AudioType
    {
        return AudioType::query()->create($attributes);
    }

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function update(AudioType $type, array $attributes): AudioType
    {
        $type->fill($attributes)->save();

        return $type->refresh();
    }

    public function delete(AudioType $type): void
    {
        $type->delete();
    }
}
