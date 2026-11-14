<?php

namespace App\Services;

use App\Enums\AudioStatus;
use App\Http\Resources\Api\V1\AudioCategoryResource;
use App\Http\Resources\Api\V1\AudioResource;
use App\Http\Resources\Api\V1\AudioTypeResource;
use App\Http\Resources\Api\V1\TeacherResource;
use App\Models\Audio;
use App\Models\Teacher;
use App\Support\ApiCache;
use Illuminate\Database\Eloquent\Model;

class CatalogCacheService
{
    public const DEFAULT_AUDIO_LIMIT = 20;

    public function __construct(
        private readonly ApiCache $cache,
        private readonly HomeService $home,
        private readonly AudioService $audios,
        private readonly TeacherService $teachers,
        private readonly AudioCategoryService $categories,
        private readonly AudioTypeService $types,
    ) {}

    /**
     * @return array{featured: array<int, mixed>, latest: array<int, mixed>, teachers: array<int, mixed>, categories: array<int, mixed>, audio_types: array<int, mixed>}
     */
    public function home(): array
    {
        return $this->cache->remember('home', function (): array {
            $content = $this->home->build();

            return [
                'featured' => AudioResource::collection($content['featured'])->resolve(),
                'latest' => AudioResource::collection($content['latest'])->resolve(),
                'teachers' => TeacherResource::collection($content['teachers'])->resolve(),
                'categories' => AudioCategoryResource::collection($content['categories'])->resolve(),
                'audio_types' => AudioTypeResource::collection($content['types'])->resolve(),
            ];
        });
    }

    /**
     * @param  array{query?: string|null, teacher?: string|null, category?: string|null, type?: string|null, cursor?: string|null}  $filters
     * @return array{data: array<int, mixed>, meta: array{pagination: array{next_cursor: string|null, has_more: bool, total: int}}}
     */
    public function audioIndex(array $filters, int $limit): array
    {
        return $this->cache->remember(
            'audios:index:'.sha1(json_encode([$filters, $limit])),
            function () use ($filters, $limit): array {
                $result = $this->audios->publicList($filters, $limit);

                return [
                    'data' => AudioResource::collection($result['audios']->items())->resolve(),
                    'meta' => [
                        'pagination' => [
                            'next_cursor' => $result['audios']->nextCursor()?->encode(),
                            'has_more' => $result['audios']->hasMorePages(),
                            'total' => $result['total'],
                        ],
                    ],
                ];
            },
        );
    }

    /**
     * @return array{data: array<string, mixed>}
     */
    public function audio(string $slug): array
    {
        return $this->cache->remember(
            'audios:show:'.$slug,
            fn (): array => [
                'data' => AudioResource::make($this->audios->findPublishedBySlug($slug))->resolve(),
            ],
        );
    }

    /**
     * @return array{data: array<int, mixed>}
     */
    public function teachers(): array
    {
        return $this->cache->remember(
            'teachers:index',
            fn (): array => [
                'data' => TeacherResource::collection($this->teachers->activeList())->resolve(),
            ],
        );
    }

    /**
     * @return array{data: array<string, mixed>}|null
     */
    public function teacher(string $slug): ?array
    {
        return $this->cache->remember(
            'teachers:show:'.$slug,
            function () use ($slug): ?array {
                $teacher = $this->teachers->findBySlug($slug);

                if (! $teacher->is_active) {
                    return null;
                }

                return [
                    'data' => TeacherResource::make($teacher)->resolve(),
                ];
            },
        );
    }

    /**
     * @return array{data: array<int, mixed>}
     */
    public function categories(): array
    {
        return $this->cache->remember(
            'categories:index',
            fn (): array => [
                'data' => AudioCategoryResource::collection($this->categories->activeList())->resolve(),
            ],
        );
    }

    /**
     * @return array{data: array<int, mixed>}
     */
    public function types(): array
    {
        return $this->cache->remember(
            'audio-types:index',
            fn (): array => [
                'data' => AudioTypeResource::collection($this->types->activeList())->resolve(),
            ],
        );
    }

    /**
     * Invalidate every cached API response.
     */
    public function flush(): void
    {
        $this->cache->flush();
    }

    /**
     * Repopulate the API cache with fresh data from the database.
     */
    public function warm(?Model $subject = null): void
    {
        $this->home();
        $this->audioIndex($this->defaultAudioFilters(), self::DEFAULT_AUDIO_LIMIT);
        $this->teachers();
        $this->categories();
        $this->types();

        if ($subject instanceof Audio) {
            $this->warmAudio($subject);
        } elseif ($subject instanceof Teacher) {
            $this->warmTeacher($subject);
        }
    }

    private function warmAudio(Audio $audio): void
    {
        if ($audio->status === AudioStatus::Published) {
            $this->audio($audio->slug);
        }
    }

    private function warmTeacher(Teacher $teacher): void
    {
        if ($teacher->is_active) {
            $this->teacher($teacher->slug);
        }
    }

    /**
     * @return array{query: null, teacher: null, category: null, type: null, cursor: null}
     */
    private function defaultAudioFilters(): array
    {
        return [
            'query' => null,
            'teacher' => null,
            'category' => null,
            'type' => null,
            'cursor' => null,
        ];
    }
}
