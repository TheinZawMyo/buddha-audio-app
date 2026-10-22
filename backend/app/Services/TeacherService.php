<?php

namespace App\Services;

use App\Models\Teacher;
use App\Repositories\Contracts\TeacherRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Http\UploadedFile;

class TeacherService
{
    public function __construct(
        private readonly TeacherRepositoryInterface $teachers,
        private readonly SlugService $slugs,
        private readonly MediaService $media,
        private readonly AuditService $audit,
    ) {}

    public function paginateForAdmin(?string $search): LengthAwarePaginator
    {
        return $this->teachers->paginateForAdmin($search, (int) config('catalog.per_page', 15));
    }

    /**
     * @return Collection<int, Teacher>
     */
    public function activeList(): Collection
    {
        return $this->teachers->activeList();
    }

    /**
     * @return Collection<int, Teacher>
     */
    public function options(): Collection
    {
        return $this->teachers->options();
    }

    public function findBySlug(string $slug): Teacher
    {
        return $this->teachers->findBySlug($slug);
    }

    public function findById(string $id): Teacher
    {
        return $this->teachers->findById($id);
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data, ?UploadedFile $photo = null): Teacher
    {
        $data['slug'] = $this->slugs->resolve(Teacher::class, $data['slug'] ?? null, $data['name']);
        $data['is_active'] = (bool) ($data['is_active'] ?? false);

        if ($photo) {
            $data['photo_path'] = $this->media->storeImage($photo, 'teachers');
        }

        $teacher = $this->teachers->create($data);

        $this->audit->record('created', $teacher, "Teacher \"{$teacher->name}\" created.", $data);

        return $teacher;
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(Teacher $teacher, array $data, ?UploadedFile $photo = null): Teacher
    {
        $data['slug'] = $this->slugs->resolve(Teacher::class, $data['slug'] ?? null, $data['name'], $teacher->id);
        $data['is_active'] = (bool) ($data['is_active'] ?? false);

        if ($photo) {
            $this->media->deleteImage($teacher->photo_path);
            $data['photo_path'] = $this->media->storeImage($photo, 'teachers');
        }

        $updated = $this->teachers->update($teacher, $data);

        $this->audit->record('updated', $updated, "Teacher \"{$updated->name}\" updated.", $data);

        return $updated;
    }

    public function delete(Teacher $teacher): void
    {
        $this->teachers->delete($teacher);

        $this->audit->record('deleted', $teacher, "Teacher \"{$teacher->name}\" deleted.");
    }
}
