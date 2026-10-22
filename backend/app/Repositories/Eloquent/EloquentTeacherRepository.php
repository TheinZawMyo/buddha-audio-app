<?php

namespace App\Repositories\Eloquent;

use App\Models\Teacher;
use App\Repositories\Contracts\TeacherRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class EloquentTeacherRepository implements TeacherRepositoryInterface
{
    public function paginateForAdmin(?string $search, int $perPage = 15): LengthAwarePaginator
    {
        return Teacher::query()
            ->withCount('audios')
            ->when($search, function ($query, string $search): void {
                $query->where(function ($query) use ($search): void {
                    $query->where('name', 'like', "%{$search}%")
                        ->orWhere('short_name', 'like', "%{$search}%")
                        ->orWhere('slug', 'like', "%{$search}%");
                });
            })
            ->ordered()
            ->paginate($perPage)
            ->withQueryString();
    }

    /**
     * @return Collection<int, Teacher>
     */
    public function activeList(): Collection
    {
        return Teacher::query()->active()->ordered()->get();
    }

    /**
     * @return Collection<int, Teacher>
     */
    public function options(): Collection
    {
        return Teacher::query()->active()->ordered()->get();
    }

    public function count(): int
    {
        return Teacher::query()->count();
    }

    public function findBySlug(string $slug): Teacher
    {
        return Teacher::query()->where('slug', $slug)->firstOrFail();
    }

    public function findById(string $id): Teacher
    {
        return Teacher::query()->findOrFail($id);
    }

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function create(array $attributes): Teacher
    {
        return Teacher::query()->create($attributes);
    }

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function update(Teacher $teacher, array $attributes): Teacher
    {
        $teacher->fill($attributes)->save();

        return $teacher->refresh();
    }

    public function delete(Teacher $teacher): void
    {
        $teacher->delete();
    }
}
