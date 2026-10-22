<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreAudioTypeRequest;
use App\Http\Requests\Admin\UpdateAudioTypeRequest;
use App\Models\AudioType;
use App\Services\AudioTypeService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class AudioTypeController extends Controller
{
    public function index(Request $request, AudioTypeService $types): Response
    {
        $search = $request->string('search')->trim()->toString() ?: null;

        return Inertia::render('Admin/AudioTypes/Index', [
            'types' => $types->paginateForAdmin($search),
            'filters' => ['search' => $search],
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('Admin/AudioTypes/Form', [
            'type' => null,
        ]);
    }

    public function store(StoreAudioTypeRequest $request, AudioTypeService $types): RedirectResponse
    {
        $type = $types->create($request->validated());

        return redirect()
            ->route('admin.audio-types.edit', $type)
            ->with('success', 'Audio type created.');
    }

    public function edit(AudioType $audioType): Response
    {
        return Inertia::render('Admin/AudioTypes/Form', [
            'type' => $audioType,
        ]);
    }

    public function update(UpdateAudioTypeRequest $request, AudioType $audioType, AudioTypeService $types): RedirectResponse
    {
        $types->update($audioType, $request->validated());

        return redirect()
            ->route('admin.audio-types.edit', $audioType)
            ->with('success', 'Audio type updated.');
    }

    public function destroy(AudioType $audioType, AudioTypeService $types): RedirectResponse
    {
        $types->delete($audioType);

        return redirect()
            ->route('admin.audio-types.index')
            ->with('success', 'Audio type deleted.');
    }
}
