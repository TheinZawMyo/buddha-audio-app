<?php

namespace App\Services;

use App\Enums\AudioStatus;
use App\Models\Audio;
use App\Repositories\Contracts\AudioRepositoryInterface;
use Illuminate\Contracts\Pagination\CursorPaginator;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class AudioService
{
    public function __construct(
        private readonly AudioRepositoryInterface $audios,
        private readonly SlugService $slugs,
        private readonly MediaService $media,
        private readonly AuditService $audit,
    ) {}

    /**
     * @param  array{query?: string|null, teacher?: string|null, category?: string|null, type?: string|null, cursor?: string|null}  $filters
     * @return array{audios: CursorPaginator, total: int}
     */
    public function publicList(array $filters, int $limit): array
    {
        return [
            'audios' => $this->audios->publicPaginate($filters, $limit),
            'total' => $this->audios->publicCount($filters),
        ];
    }

    public function findPublishedBySlug(string $slug): Audio
    {
        return $this->audios->findPublishedBySlug($slug);
    }

    /**
     * @return Collection<int, Audio>
     */
    public function latestPublished(int $limit): Collection
    {
        return $this->audios->latestPublished($limit);
    }

    /**
     * @param  array{query?: string|null, status?: string|null, teacher?: string|null}  $filters
     */
    public function paginateForAdmin(array $filters): LengthAwarePaginator
    {
        return $this->audios->paginateForAdmin($filters, (int) config('catalog.per_page', 15));
    }

    public function findById(string $id): Audio
    {
        return $this->audios->findById($id);
    }

    /**
     * @param  array<string, mixed>  $data
     * @param  array<int, string>  $categoryIds
     */
    public function create(array $data, array $categoryIds, ?UploadedFile $audioFile = null, ?UploadedFile $cover = null): Audio
    {
        $audioUploadPath = $data['audio_upload_path'] ?? null;
        $audioOriginalName = $data['audio_original_name'] ?? null;
        unset($data['audio_upload_path'], $data['audio_original_name'], $data['audio_mime'], $data['audio_size']);

        $data['slug'] = $this->slugs->resolve(Audio::class, $data['slug'] ?? null, $data['title']);
        $data['status'] = AudioStatus::Draft;
        $data['published_at'] = null;
        $data['created_by'] = Auth::id();
        $data['updated_by'] = Auth::id();

        if ($audioFile) {
            $data = [...$data, ...$this->media->storeAudio($audioFile)];
        } elseif (filled($audioUploadPath)) {
            $data = [...$data, ...$this->media->finalizeAudioSelection(
                $audioUploadPath,
                (string) $audioOriginalName,
            )];
        }

        if ($cover) {
            $data['cover_path'] = $this->media->storeCover($cover);
        }

        $audio = $this->audios->create($data, $categoryIds);

        $this->audit->record('created', $audio, "Audio \"{$audio->title}\" created as draft.", $data);

        return $audio;
    }

    /**
     * @param  array<string, mixed>  $data
     * @param  array<int, string>  $categoryIds
     */
    public function update(Audio $audio, array $data, array $categoryIds, ?UploadedFile $audioFile = null, ?UploadedFile $cover = null): Audio
    {
        $audioUploadPath = $data['audio_upload_path'] ?? null;
        $audioOriginalName = $data['audio_original_name'] ?? null;
        unset($data['audio_upload_path'], $data['audio_original_name'], $data['audio_mime'], $data['audio_size']);

        $data['slug'] = $this->slugs->resolve(Audio::class, $data['slug'] ?? null, $data['title'], $audio->id);
        $data['updated_by'] = Auth::id();

        $previousAudioPath = null;
        if ($audioFile) {
            $previousAudioPath = $audio->audio_path;
            $data = [...$data, ...$this->media->storeAudio($audioFile)];
        } elseif (filled($audioUploadPath)) {
            $previousAudioPath = $audio->audio_path;
            $data = [...$data, ...$this->media->finalizeAudioSelection(
                $audioUploadPath,
                (string) $audioOriginalName,
            )];
        }

        if ($cover) {
            $this->media->deleteImage($audio->cover_path);
            $data['cover_path'] = $this->media->storeCover($cover);
        }

        $updated = $this->audios->update($audio, $data, $categoryIds);

        if ($previousAudioPath !== null && $updated->audio_path !== $previousAudioPath) {
            $this->media->deleteAudio($previousAudioPath);
        }

        $this->audit->record('updated', $updated, "Audio \"{$updated->title}\" updated.", $data);

        return $updated;
    }

    public function publish(Audio $audio): Audio
    {
        if (! $audio->hasPlayableAsset()) {
            throw ValidationException::withMessages([
                'publish' => 'Upload an audio file or set an external playback URL before publishing.',
            ]);
        }

        if ($audio->duration_seconds < 1) {
            throw ValidationException::withMessages([
                'publish' => 'The audio duration must be at least one second before publishing.',
            ]);
        }

        $audio->forceFill([
            'status' => AudioStatus::Published,
            'published_at' => $audio->published_at ?? now(),
            'updated_by' => Auth::id(),
        ])->save();

        $this->audit->record('published', $audio, "Audio \"{$audio->title}\" published.");

        return $audio->refresh();
    }

    public function archive(Audio $audio): Audio
    {
        $audio->forceFill([
            'status' => AudioStatus::Archived,
            'updated_by' => Auth::id(),
        ])->save();

        $this->audit->record('archived', $audio, "Audio \"{$audio->title}\" archived.");

        return $audio->refresh();
    }

    public function delete(Audio $audio): void
    {
        $this->audios->delete($audio);

        $this->audit->record('deleted', $audio, "Audio \"{$audio->title}\" deleted.");
    }
}
