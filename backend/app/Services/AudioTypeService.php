<?php

namespace App\Services;

use App\Models\AudioType;
use App\Repositories\Contracts\AudioTypeRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class AudioTypeService
{
    public function __construct(
        private readonly AudioTypeRepositoryInterface $types,
        private readonly SlugService $slugs,
        private readonly AuditService $audit,
    ) {}

    public function paginateForAdmin(?string $search): LengthAwarePaginator
    {
        return $this->types->paginateForAdmin($search, (int) config('catalog.per_page', 15));
    }

    /**
     * @return Collection<int, AudioType>
     */
    public function activeList(): Collection
    {
        return $this->types->activeList();
    }

    /**
     * @return Collection<int, AudioType>
     */
    public function options(): Collection
    {
        return $this->types->options();
    }

    public function findBySlug(string $slug): AudioType
    {
        return $this->types->findBySlug($slug);
    }

    public function findById(string $id): AudioType
    {
        return $this->types->findById($id);
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data): AudioType
    {
        $data['slug'] = $this->slugs->resolve(AudioType::class, $data['slug'] ?? null, $data['name']);
        $data['is_active'] = (bool) ($data['is_active'] ?? false);

        $type = $this->types->create($data);

        $this->audit->record('created', $type, "Audio type \"{$type->name}\" created.", $data);

        return $type;
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(AudioType $type, array $data): AudioType
    {
        $data['slug'] = $this->slugs->resolve(AudioType::class, $data['slug'] ?? null, $data['name'], $type->id);
        $data['is_active'] = (bool) ($data['is_active'] ?? false);

        $updated = $this->types->update($type, $data);

        $this->audit->record('updated', $updated, "Audio type \"{$updated->name}\" updated.", $data);

        return $updated;
    }

    public function delete(AudioType $type): void
    {
        $this->types->delete($type);

        $this->audit->record('deleted', $type, "Audio type \"{$type->name}\" deleted.");
    }
}
