<?php

namespace App\Services;

use App\Models\Audio;
use App\Models\AudioCategory;
use App\Models\AudioType;
use App\Models\Teacher;
use App\Repositories\Contracts\AudioCategoryRepositoryInterface;
use App\Repositories\Contracts\AudioTypeRepositoryInterface;
use App\Repositories\Contracts\FeaturedAudioRepositoryInterface;
use App\Repositories\Contracts\TeacherRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class HomeService
{
    public function __construct(
        private readonly AudioService $audios,
        private readonly TeacherRepositoryInterface $teachers,
        private readonly AudioCategoryRepositoryInterface $categories,
        private readonly AudioTypeRepositoryInterface $types,
        private readonly FeaturedAudioRepositoryInterface $featuredAudios,
    ) {}

    /**
     * @return array{
     *     featured: Collection<int, Audio>,
     *     latest: Collection<int, Audio>,
     *     teachers: Collection<int, Teacher>,
     *     categories: Collection<int, AudioCategory>,
     *     types: Collection<int, AudioType>
     * }
     */
    public function build(): array
    {
        $latestLimit = (int) config('catalog.home.latest_limit', 8);
        $featuredLimit = (int) config('catalog.home.featured_limit', 4);

        $featured = $this->featuredAudios->featuredAudios($featuredLimit);

        if ($featured->isEmpty()) {
            $featured = $this->audios->latestPublished($featuredLimit);
        }

        return [
            'featured' => $featured,
            'latest' => $this->audios->latestPublished($latestLimit),
            'teachers' => $this->teachers->activeList(),
            'categories' => $this->categories->activeList(),
            'types' => $this->types->activeList(),
        ];
    }
}
