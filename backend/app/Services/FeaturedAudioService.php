<?php

namespace App\Services;

use App\Models\Audio;
use App\Models\FeaturedAudio;
use App\Repositories\Contracts\FeaturedAudioRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class FeaturedAudioService
{
    public function __construct(
        private readonly FeaturedAudioRepositoryInterface $featuredAudios,
        private readonly AuditService $audit,
    ) {}

    public function paginateForAdmin(?string $search): LengthAwarePaginator
    {
        return $this->featuredAudios->paginateForAdmin($search, (int) config('catalog.per_page', 15));
    }

    /**
     * @return Collection<int, Audio>
     */
    public function featuredAudios(int $limit): Collection
    {
        return $this->featuredAudios->featuredAudios($limit);
    }

    /**
     * @return Collection<int, Audio>
     */
    public function publishedOptions(): Collection
    {
        return $this->featuredAudios->publishedOptions();
    }

    public function findById(string $id): FeaturedAudio
    {
        return $this->featuredAudios->findById($id);
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(array $data): FeaturedAudio
    {
        $data['is_active'] = (bool) ($data['is_active'] ?? false);

        $featured = $this->featuredAudios->create($data)->load('audio');

        $this->audit->record(
            'created',
            $featured,
            "Audio \"{$featured->audio?->title}\" added to featured list.",
            $data,
        );

        return $featured;
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(FeaturedAudio $featuredAudio, array $data): FeaturedAudio
    {
        $data['is_active'] = (bool) ($data['is_active'] ?? false);

        $updated = $this->featuredAudios->update($featuredAudio, $data)->load('audio');

        $this->audit->record(
            'updated',
            $updated,
            "Featured list entry for \"{$updated->audio?->title}\" updated.",
            $data,
        );

        return $updated;
    }

    public function delete(FeaturedAudio $featuredAudio): void
    {
        $featuredAudio->loadMissing('audio');

        $this->featuredAudios->delete($featuredAudio);

        $this->audit->record(
            'deleted',
            $featuredAudio,
            "Audio \"{$featuredAudio->audio?->title}\" removed from featured list.",
        );
    }
}
