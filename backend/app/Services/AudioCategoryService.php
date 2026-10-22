<?php

namespace App\Services;

use App\Models\AudioCategory;
use App\Repositories\Contracts\AudioCategoryRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class AudioCategoryService
{
    public function __construct(
        private readonly AudioCategoryRepositoryInterface $categories,
        private readonly SlugService $slugs,
        private readonly AuditService $audit,
    ) {}

    public function paginateForAdmin(?string $search): LengthAwarePaginator
    {
        return $this->categories->paginateForAdmin($search, (int) config('catalog.per_page', 15));
    }

    /**
     * @return Collection<int, AudioCategory>
     */
    public function activeList(): Collection
    {
        return $this->categories->activeList();
    }

    /**
     * @return Collection<int, AudioCategory>
     */
    public function options(): Collection
    {
        return $this->categories->options();
    }

    public function findBySlug(string $slug): AudioCategory
    {
        return $this->categories->findBySlug($slug);
    }

    public function findById(string $id): AudioCategory
    {
        return $this->categories->findById($id);
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data): AudioCategory
    {
        $data['slug'] = $this->slugs->resolve(AudioCategory::class, $data['slug'] ?? null, $data['name']);
        $data['is_active'] = (bool) ($data['is_active'] ?? false);

        $category = $this->categories->create($data);

        $this->audit->record('created', $category, "Category \"{$category->name}\" created.", $data);

        return $category;
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(AudioCategory $category, array $data): AudioCategory
    {
        $data['slug'] = $this->slugs->resolve(AudioCategory::class, $data['slug'] ?? null, $data['name'], $category->id);
        $data['is_active'] = (bool) ($data['is_active'] ?? false);

        $updated = $this->categories->update($category, $data);

        $this->audit->record('updated', $updated, "Category \"{$updated->name}\" updated.", $data);

        return $updated;
    }

    public function delete(AudioCategory $category): void
    {
        $this->categories->delete($category);

        $this->audit->record('deleted', $category, "Category \"{$category->name}\" deleted.");
    }
}
