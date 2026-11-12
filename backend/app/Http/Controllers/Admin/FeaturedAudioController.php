<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreFeaturedAudioRequest;
use App\Http\Requests\Admin\UpdateFeaturedAudioRequest;
use App\Models\Audio;
use App\Models\FeaturedAudio;
use App\Services\FeaturedAudioService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Inertia\Inertia;
use Inertia\Response;

class FeaturedAudioController extends Controller
{
    public function index(Request $request, FeaturedAudioService $featuredAudios): Response
    {
        $search = $request->string('search')->trim()->toString() ?: null;

        return Inertia::render('Admin/FeaturedAudios/Index', [
            'featuredAudios' => $featuredAudios->paginateForAdmin($search),
            'filters' => ['search' => $search],
        ]);
    }

    public function create(FeaturedAudioService $featuredAudios): Response
    {
        return Inertia::render('Admin/FeaturedAudios/Form', [
            'featuredAudio' => null,
            'audios' => $this->audioOptions($featuredAudios),
        ]);
    }

    public function store(StoreFeaturedAudioRequest $request, FeaturedAudioService $featuredAudios): RedirectResponse
    {
        $featuredAudios->create($request->validated());

        return redirect()
            ->route('admin.featured-audios.index')
            ->with('success', 'Featured audio added.');
    }

    public function edit(FeaturedAudio $featuredAudio, FeaturedAudioService $featuredAudios): Response
    {
        return Inertia::render('Admin/FeaturedAudios/Form', [
            'featuredAudio' => $featuredAudio->load('audio'),
            'audios' => $this->audioOptions($featuredAudios),
        ]);
    }

    public function update(
        UpdateFeaturedAudioRequest $request,
        FeaturedAudio $featuredAudio,
        FeaturedAudioService $featuredAudios,
    ): RedirectResponse {
        $featuredAudios->update($featuredAudio, $request->validated());

        return redirect()
            ->route('admin.featured-audios.index')
            ->with('success', 'Featured audio updated.');
    }

    public function destroy(FeaturedAudio $featuredAudio, FeaturedAudioService $featuredAudios): RedirectResponse
    {
        $featuredAudios->delete($featuredAudio);

        return redirect()
            ->route('admin.featured-audios.index')
            ->with('success', 'Featured audio removed.');
    }

    /**
     * @return Collection<int, array<string, mixed>>
     */
    private function audioOptions(FeaturedAudioService $featuredAudios): Collection
    {
        return $featuredAudios->publishedOptions()->map(fn (Audio $audio): array => [
            'id' => $audio->id,
            'title' => $audio->title,
            'slug' => $audio->slug,
            'teacher_name' => $audio->teacher?->name,
        ])->values();
    }
}
