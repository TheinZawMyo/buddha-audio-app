<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreAudioCategoryRequest;
use App\Http\Requests\Admin\UpdateAudioCategoryRequest;
use App\Models\AudioCategory;
use App\Services\AudioCategoryService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class AudioCategoryController extends Controller
{
    public function index(Request $request, AudioCategoryService $categories): Response
    {
        $search = $request->string('search')->trim()->toString() ?: null;

        return Inertia::render('Admin/Categories/Index', [
            'categories' => $categories->paginateForAdmin($search),
            'filters' => ['search' => $search],
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('Admin/Categories/Form', [
            'category' => null,
        ]);
    }

    public function store(StoreAudioCategoryRequest $request, AudioCategoryService $categories): RedirectResponse
    {
        $category = $categories->create($request->validated());

        return redirect()
            ->route('admin.categories.edit', $category)
            ->with('success', 'Category created.');
    }

    public function edit(AudioCategory $category): Response
    {
        return Inertia::render('Admin/Categories/Form', [
            'category' => $category,
        ]);
    }

    public function update(UpdateAudioCategoryRequest $request, AudioCategory $category, AudioCategoryService $categories): RedirectResponse
    {
        $categories->update($category, $request->validated());

        return redirect()
            ->route('admin.categories.edit', $category)
            ->with('success', 'Category updated.');
    }

    public function destroy(AudioCategory $category, AudioCategoryService $categories): RedirectResponse
    {
        $categories->delete($category);

        return redirect()
            ->route('admin.categories.index')
            ->with('success', 'Category deleted.');
    }
}
