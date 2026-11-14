<?php

use App\Http\Controllers\Admin\ApiKeyController;
use App\Http\Controllers\Admin\AudioCategoryController;
use App\Http\Controllers\Admin\AudioController;
use App\Http\Controllers\Admin\AudioTypeController;
use App\Http\Controllers\Admin\AuditLogController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\FeaturedAudioController;
use App\Http\Controllers\Admin\PasswordController;
use App\Http\Controllers\Admin\TeacherController;
use App\Http\Controllers\Admin\TusUploadController;
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
        Route::resource('featured-audios', FeaturedAudioController::class)
            ->except('show')
            ->parameters(['featured-audios' => 'featuredAudio']);

        Route::post('audios/{audio}/publish', [AudioController::class, 'publish'])->name('audios.publish');
        Route::post('audios/{audio}/archive', [AudioController::class, 'archive'])->name('audios.archive');

        Route::post('audios/tus', [TusUploadController::class, 'create'])->name('audios.tus.create');
        Route::match(['options'], 'audios/tus', [TusUploadController::class, 'options'])->name('audios.tus.options');
        Route::match(['head'], 'audios/tus/{upload}', [TusUploadController::class, 'head'])->name('audios.tus.head');
        Route::patch('audios/tus/{upload}', [TusUploadController::class, 'patch'])->name('audios.tus.patch');
        Route::delete('audios/tus/{upload}', [TusUploadController::class, 'destroy'])->name('audios.tus.destroy');
        Route::match(['options'], 'audios/tus/{upload}', [TusUploadController::class, 'options']);
        Route::post('audios/tus/{upload}/complete', [TusUploadController::class, 'complete'])->name('audios.tus.complete');

        Route::post('audios/upload', [AudioController::class, 'upload'])->name('audios.upload');
        Route::delete('audios/upload/{filename}', [AudioController::class, 'discardUpload'])
            ->where('filename', '[A-Za-z0-9._-]+')
            ->name('audios.upload.discard');
        Route::resource('audios', AudioController::class)->except('show');

        Route::get('audit-logs', [AuditLogController::class, 'index'])->name('audit-logs.index');
        Route::resource('api-keys', ApiKeyController::class)
            ->except('show')
            ->parameters(['api-keys' => 'apiKey'])
            ->middleware('can:manage-api-keys');

        Route::get('password', [PasswordController::class, 'edit'])->name('password.edit');
    });

require __DIR__.'/auth.php';
