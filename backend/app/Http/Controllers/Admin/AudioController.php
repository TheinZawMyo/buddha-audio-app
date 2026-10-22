<?php

namespace App\Http\Controllers\Admin;

use App\Enums\AudioStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreAudioRequest;
use App\Http\Requests\Admin\UpdateAudioRequest;
use App\Models\Audio;
use App\Services\AudioCategoryService;
use App\Services\AudioService;
use App\Services\AudioTypeService;
use App\Services\TeacherService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class AudioController extends Controller
{
    public function index(Request $request, AudioService $audios, TeacherService $teachers): Response
    {
        $filters = [
            'query' => $request->string('search')->trim()->toString() ?: null,
            'status' => $request->string('status')->trim()->toString() ?: null,
            'teacher' => $request->string('teacher')->trim()->toString() ?: null,
        ];

        return Inertia::render('Admin/Audios/Index', [
            'audios' => $audios->paginateForAdmin($filters),
            'filters' => $filters,
            'teachers' => $teachers->options(),
            'statuses' => collect(AudioStatus::cases())->map(fn (AudioStatus $status): array => [
                'value' => $status->value,
                'label' => $status->label(),
            ]),
        ]);
    }

    public function create(TeacherService $teachers, AudioCategoryService $categories, AudioTypeService $types): Response
    {
        return Inertia::render('Admin/Audios/Form', [
            'audio' => null,
            ...$this->formOptions($teachers, $categories, $types),
        ]);
    }

    public function store(StoreAudioRequest $request, AudioService $audios): RedirectResponse
    {
        $audio = $audios->create(
            $request->safe()->except(['categories', 'audio_file', 'cover_image']),
            $request->input('categories', []),
            $request->file('audio_file'),
            $request->file('cover_image'),
        );

        return redirect()
            ->route('admin.audios.edit', $audio)
            ->with('success', 'Audio saved as draft.');
    }

    public function edit(Audio $audio, TeacherService $teachers, AudioCategoryService $categories, AudioTypeService $types): Response
    {
        return Inertia::render('Admin/Audios/Form', [
            'audio' => $audio->load(['teacher', 'audioType', 'categories']),
            ...$this->formOptions($teachers, $categories, $types),
        ]);
    }

    public function update(UpdateAudioRequest $request, Audio $audio, AudioService $audios): RedirectResponse
    {
        $audios->update(
            $audio,
            $request->safe()->except(['categories', 'audio_file', 'cover_image']),
            $request->input('categories', []),
            $request->file('audio_file'),
            $request->file('cover_image'),
        );

        return redirect()
            ->route('admin.audios.edit', $audio)
            ->with('success', 'Audio updated.');
    }

    public function publish(Audio $audio, AudioService $audios): RedirectResponse
    {
        $audios->publish($audio);

        return back()->with('success', 'Audio published.');
    }

    public function archive(Audio $audio, AudioService $audios): RedirectResponse
    {
        $audios->archive($audio);

        return back()->with('success', 'Audio archived.');
    }

    public function destroy(Audio $audio, AudioService $audios): RedirectResponse
    {
        $audios->delete($audio);

        return redirect()
            ->route('admin.audios.index')
            ->with('success', 'Audio deleted.');
    }

    /**
     * @return array<string, mixed>
     */
    private function formOptions(TeacherService $teachers, AudioCategoryService $categories, AudioTypeService $types): array
    {
        return [
            'teachers' => $teachers->options(),
            'categories' => $categories->options(),
            'audioTypes' => $types->options(),
        ];
    }
}
