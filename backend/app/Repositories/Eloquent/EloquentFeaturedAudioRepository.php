<?php

namespace App\Repositories\Eloquent;

use App\Models\Audio;
use App\Models\FeaturedAudio;
use App\Repositories\Contracts\FeaturedAudioRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class EloquentFeaturedAudioRepository implements FeaturedAudioRepositoryInterface
{
    public function paginateForAdmin(?string $search, int $perPage = 15): LengthAwarePaginator
    {
        return FeaturedAudio::query()
            ->with(['audio.teacher', 'audio.audioType'])
            ->when($search, function ($query, string $search): void {
                $query->whereHas('audio', function ($query) use ($search): void {
                    $query->where('title', 'like', "%{$search}%")
                        ->orWhereHas('teacher', function ($query) use ($search): void {
                            $query->where('name', 'like', "%{$search}%");
                        });
                });
            })
            ->ordered()
            ->paginate($perPage)
            ->withQueryString();
    }

    /**
     * @return Collection<int, Audio>
     */
    public function featuredAudios(int $limit): Collection
    {
        return Audio::query()
            ->published()
            ->withCatalog()
            ->join('featured_audios', 'audios.id', '=', 'featured_audios.audio_id')
            ->where('featured_audios.is_active', true)
            ->orderBy('featured_audios.sort_order')
            ->orderBy('featured_audios.created_at')
            ->limit($limit)
            ->select('audios.*')
            ->get();
    }

    /**
     * @return Collection<int, Audio>
     */
    public function publishedOptions(): Collection
    {
        return Audio::query()
            ->published()
            ->with('teacher')
            ->orderBy('title')
            ->get();
    }

    public function findById(string $id): FeaturedAudio
    {
        return FeaturedAudio::query()->with('audio')->findOrFail($id);
    }

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function create(array $attributes): FeaturedAudio
    {
        return FeaturedAudio::query()->create($attributes);
    }

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function update(FeaturedAudio $featuredAudio, array $attributes): FeaturedAudio
    {
        $featuredAudio->fill($attributes)->save();

        return $featuredAudio->refresh();
    }

    public function delete(FeaturedAudio $featuredAudio): void
    {
        $featuredAudio->delete();
    }
}
