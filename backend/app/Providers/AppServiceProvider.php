<?php

namespace App\Providers;

use App\Repositories\Contracts\AudioCategoryRepositoryInterface;
use App\Repositories\Contracts\AudioRepositoryInterface;
use App\Repositories\Contracts\AudioTypeRepositoryInterface;
use App\Repositories\Contracts\AuditLogRepositoryInterface;
use App\Repositories\Contracts\TeacherRepositoryInterface;
use App\Repositories\Eloquent\EloquentAudioCategoryRepository;
use App\Repositories\Eloquent\EloquentAudioRepository;
use App\Repositories\Eloquent\EloquentAudioTypeRepository;
use App\Repositories\Eloquent\EloquentAuditLogRepository;
use App\Repositories\Eloquent\EloquentTeacherRepository;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Vite;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->bind(TeacherRepositoryInterface::class, EloquentTeacherRepository::class);
        $this->app->bind(AudioCategoryRepositoryInterface::class, EloquentAudioCategoryRepository::class);
        $this->app->bind(AudioTypeRepositoryInterface::class, EloquentAudioTypeRepository::class);
        $this->app->bind(AudioRepositoryInterface::class, EloquentAudioRepository::class);
        $this->app->bind(AuditLogRepositoryInterface::class, EloquentAuditLogRepository::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Vite::prefetch(concurrency: 3);

        Model::preventLazyLoading(! app()->isProduction());
    }
}
