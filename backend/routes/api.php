<?php

use App\Http\Controllers\Api\V1\AudioCategoryController;
use App\Http\Controllers\Api\V1\AudioController;
use App\Http\Controllers\Api\V1\AudioStreamController;
use App\Http\Controllers\Api\V1\AudioTypeController;
use App\Http\Controllers\Api\V1\HomeController;
use App\Http\Controllers\Api\V1\TeacherController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->name('api.v1.')->group(function (): void {
    Route::get('/home', HomeController::class)->name('home');

    Route::get('/audios', [AudioController::class, 'index'])->name('audios.index');
    Route::get('/audios/{slug}', [AudioController::class, 'show'])->name('audios.show');
    Route::post('/audios/{slug}/playback-url', [AudioController::class, 'playbackUrl'])->name('audios.playback-url');
    Route::get('/audios/{audio:slug}/stream', AudioStreamController::class)
        ->middleware('signed')
        ->name('audios.stream');

    Route::get('/teachers', [TeacherController::class, 'index'])->name('teachers.index');
    Route::get('/teachers/{slug}', [TeacherController::class, 'show'])->name('teachers.show');

    Route::get('/categories', [AudioCategoryController::class, 'index'])->name('categories.index');

    Route::get('/audio-types', [AudioTypeController::class, 'index'])->name('audio-types.index');
});
