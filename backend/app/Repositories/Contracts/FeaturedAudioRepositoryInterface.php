<?php

namespace App\Repositories\Contracts;

use App\Models\Audio;
use App\Models\FeaturedAudio;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

interface FeaturedAudioRepositoryInterface
{
    public function paginateForAdmin(?string $search, int $perPage = 15): LengthAwarePaginator;

    /**
     * @return Collection<int, Audio>
     */
    public function featuredAudios(int $limit): Collection;

    /**
     * @return Collection<int, Audio>
     */
    public function publishedOptions(): Collection;

    public function findById(string $id): FeaturedAudio;

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function create(array $attributes): FeaturedAudio;

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function update(FeaturedAudio $featuredAudio, array $attributes): FeaturedAudio;

    public function delete(FeaturedAudio $featuredAudio): void;
}
