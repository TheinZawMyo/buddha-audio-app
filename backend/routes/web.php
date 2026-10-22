<?php

use App\Http\Controllers\Admin\AudioCategoryController;
use App\Http\Controllers\Admin\AudioController;
use App\Http\Controllers\Admin\AuditLogController;
use App\Http\Controllers\Admin\AudioTypeController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\TeacherController;
use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;

Route::redirect('/', '/admin');

Route::get('/dashboard', fn () => redirect()->route('admin.dashboard'))
    ->middleware('auth')
    ->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

Route::middleware(['auth', 'active'])
    ->prefix('admin')
    ->name('admin.')
    ->group(function (): void {
        Route::get('/', [DashboardController::class, 'index'])->name('dashboard');

        Route::resource('teachers', TeacherController::class)->except('show');
        Route::resource('categories', AudioCategoryController::class)->except('show');
        Route::resource('audio-types', AudioTypeController::class)->except('show')->parameters(['audio-types' => 'audioType']);

        Route::post('audios/{audio}/publish', [AudioController::class, 'publish'])->name('audios.publish');
        Route::post('audios/{audio}/archive', [AudioController::class, 'archive'])->name('audios.archive');
        Route::resource('audios', AudioController::class)->except('show');

        Route::get('audit-logs', [AuditLogController::class, 'index'])->name('audit-logs.index');
    });

require __DIR__.'/auth.php';
