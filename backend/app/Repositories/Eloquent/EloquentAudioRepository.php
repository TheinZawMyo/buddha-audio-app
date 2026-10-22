<?php

namespace App\Repositories\Eloquent;

use App\Enums\AudioStatus;
use App\Models\Audio;
use App\Repositories\Contracts\AudioRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Contracts\Pagination\CursorPaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

class EloquentAudioRepository implements AudioRepositoryInterface
{
    /**
     * @param  array{query?: string|null, teacher?: string|null, category?: string|null, type?: string|null, status?: string|null, cursor?: string|null}  $filters
     */
    public function publicPaginate(array $filters, int $limit): CursorPaginator
    {
        return $this->publicQuery($filters)
            ->withCatalog()
            ->latest('published_at')
            ->latest('id')
            ->cursorPaginate($limit);
    }

    /**
     * @param  array{query?: string|null, teacher?: string|null, category?: string|null, type?: string|null}  $filters
     */
    public function publicCount(array $filters): int
    {
        return $this->publicQuery($filters)->count();
    }

    public function findPublishedBySlug(string $slug): Audio
    {
        return Audio::query()
            ->published()
            ->withCatalog()
            ->where('slug', $slug)
            ->firstOrFail();
    }

    /**
     * @return Collection<int, Audio>
     */
    public function latestPublished(int $limit): Collection
    {
        return Audio::query()
            ->published()
            ->withCatalog()
            ->latest('published_at')
            ->latest('id')
            ->limit($limit)
            ->get();
    }

    /**
     * @param  array{query?: string|null, status?: string|null, teacher?: string|null}  $filters
     */
    public function paginateForAdmin(array $filters, int $perPage = 15): LengthAwarePaginator
    {
        return Audio::query()
            ->withCatalog()
            ->when($filters['query'] ?? null, function ($query, string $search): void {
                $query->where(function ($query) use ($search): void {
                    $query->where('title', 'like', "%{$search}%")
                        ->orWhere('description', 'like', "%{$search}%")
                        ->orWhereHas('teacher', function ($query) use ($search): void {
                            $query->where('name', 'like', "%{$search}%");
                        });
                });
            })
            ->when($filters['status'] ?? null, function ($query, string $status): void {
                $query->where('status', $status);
            })
            ->when($filters['teacher'] ?? null, function ($query, string $teacher): void {
                $query->whereHas('teacher', function ($query) use ($teacher): void {
                    $query->where('slug', $teacher);
                });
            })
            ->latest('created_at')
            ->latest('id')
            ->paginate($perPage)
            ->withQueryString();
    }

    public function findById(string $id): Audio
    {
        return Audio::query()->withCatalog()->findOrFail($id);
    }

    /**
     * @param  array<string, mixed>  $attributes
     * @param  array<int, string>  $categoryIds
     */
    public function create(array $attributes, array $categoryIds): Audio
    {
        return DB::transaction(function () use ($attributes, $categoryIds): Audio {
            $audio = Audio::query()->create($attributes);
            $audio->categories()->sync($categoryIds);

            return $audio->load(['teacher', 'audioType', 'categories']);
        });
    }

    /**
     * @param  array<string, mixed>  $attributes
     * @param  array<int, string>  $categoryIds
     */
    public function update(Audio $audio, array $attributes, array $categoryIds): Audio
    {
        return DB::transaction(function () use ($audio, $attributes, $categoryIds): Audio {
            $audio->fill($attributes)->save();
            $audio->categories()->sync($categoryIds);

            return $audio->refresh()->load(['teacher', 'audioType', 'categories']);
        });
    }

    public function delete(Audio $audio): void
    {
        $audio->delete();
    }

    /**
     * @return array<string, int>
     */
    public function countsByStatus(): array
    {
        $counts = Audio::query()
            ->selectRaw('status, count(*) as aggregate')
            ->groupBy('status')
            ->pluck('aggregate', 'status');

        $result = [];

        foreach (AudioStatus::cases() as $status) {
            $result[$status->value] = (int) ($counts[$status->value] ?? 0);
        }

        return $result;
    }

    /**
     * @return Collection<int, Audio>
     */
    public function recent(int $limit): Collection
    {
        return Audio::query()
            ->withCatalog()
            ->latest('created_at')
            ->latest('id')
            ->limit($limit)
            ->get();
    }

    /**
     * @param  array{query?: string|null, teacher?: string|null, category?: string|null, type?: string|null}  $filters
     */
    private function publicQuery(array $filters): Builder
    {
        return Audio::query()
            ->published()
            ->when($filters['query'] ?? null, function ($query, string $search): void {
                $query->where(function ($query) use ($search): void {
                    $query->where('title', 'like', "%{$search}%")
                        ->orWhere('description', 'like', "%{$search}%")
                        ->orWhereHas('teacher', function ($query) use ($search): void {
                            $query->where('name', 'like', "%{$search}%")
                                ->orWhere('short_name', 'like', "%{$search}%");
                        });
                });
            })
            ->when($filters['teacher'] ?? null, function ($query, string $teacher): void {
                $query->whereHas('teacher', function ($query) use ($teacher): void {
                    $query->where('slug', $teacher);
                });
            })
            ->when($filters['category'] ?? null, function ($query, string $category): void {
                $query->whereHas('categories', function ($query) use ($category): void {
                    $query->where('slug', $category);
                });
            })
            ->when($filters['type'] ?? null, function ($query, string $type): void {
                $query->whereHas('audioType', function ($query) use ($type): void {
                    $query->where('slug', $type);
                });
            });
    }
}
