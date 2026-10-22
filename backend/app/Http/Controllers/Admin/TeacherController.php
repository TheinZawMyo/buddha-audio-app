<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreTeacherRequest;
use App\Http\Requests\Admin\UpdateTeacherRequest;
use App\Models\Teacher;
use App\Services\TeacherService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class TeacherController extends Controller
{
    public function index(Request $request, TeacherService $teachers): Response
    {
        $search = $request->string('search')->trim()->toString() ?: null;

        return Inertia::render('Admin/Teachers/Index', [
            'teachers' => $teachers->paginateForAdmin($search),
            'filters' => ['search' => $search],
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('Admin/Teachers/Form', [
            'teacher' => null,
        ]);
    }

    public function store(StoreTeacherRequest $request, TeacherService $teachers): RedirectResponse
    {
        $teacher = $teachers->create(
            $request->safe()->except('photo'),
            $request->file('photo'),
        );

        return redirect()
            ->route('admin.teachers.edit', $teacher)
            ->with('success', 'Teacher created.');
    }

    public function edit(Teacher $teacher): Response
    {
        return Inertia::render('Admin/Teachers/Form', [
            'teacher' => $teacher,
        ]);
    }

    public function update(UpdateTeacherRequest $request, Teacher $teacher, TeacherService $teachers): RedirectResponse
    {
        $teachers->update(
            $teacher,
            $request->safe()->except('photo'),
            $request->file('photo'),
        );

        return redirect()
            ->route('admin.teachers.edit', $teacher)
            ->with('success', 'Teacher updated.');
    }

    public function destroy(Teacher $teacher, TeacherService $teachers): RedirectResponse
    {
        $teachers->delete($teacher);

        return redirect()
            ->route('admin.teachers.index')
            ->with('success', 'Teacher deleted.');
    }
}
