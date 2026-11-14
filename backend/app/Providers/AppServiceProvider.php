<?php

namespace App\Providers;

use App\Models\Audio;
use App\Models\AudioCategory;
use App\Models\AudioType;
use App\Models\FeaturedAudio;
use App\Models\Teacher;
use App\Models\User;
use App\Repositories\Contracts\AudioCategoryRepositoryInterface;
use App\Repositories\Contracts\AudioRepositoryInterface;
use App\Repositories\Contracts\AudioTypeRepositoryInterface;
use App\Repositories\Contracts\AuditLogRepositoryInterface;
use App\Repositories\Contracts\FeaturedAudioRepositoryInterface;
use App\Repositories\Contracts\TeacherRepositoryInterface;
use App\Repositories\Eloquent\EloquentAudioCategoryRepository;
use App\Repositories\Eloquent\EloquentAudioRepository;
use App\Repositories\Eloquent\EloquentAudioTypeRepository;
use App\Repositories\Eloquent\EloquentAuditLogRepository;
use App\Repositories\Eloquent\EloquentFeaturedAudioRepository;
use App\Repositories\Eloquent\EloquentTeacherRepository;
use App\Services\CatalogCacheService;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
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
        $this->app->bind(FeaturedAudioRepositoryInterface::class, EloquentFeaturedAudioRepository::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Vite::prefetch(concurrency: 3);

        Gate::define('manage-api-keys', fn (User $user): bool => $user->isAdmin());

        Model::preventLazyLoading(! app()->isProduction());

        $this->syncApiCacheOnCatalogChanges();
    }

    private function syncApiCacheOnCatalogChanges(): void
    {
        $models = [Audio::class, AudioCategory::class, AudioType::class, FeaturedAudio::class, Teacher::class];

        foreach ($models as $model) {
            $model::saved(function (Model $instance): void {
                $cache = app(CatalogCacheService::class);

                $cache->flush();

                if (! app()->runningUnitTests()) {
                    DB::afterCommit(fn () => $cache->warm($instance));
                }
            });

            $model::deleted(function (): void {
                $cache = app(CatalogCacheService::class);

                $cache->flush();

                if (! app()->runningUnitTests()) {
                    DB::afterCommit(fn () => $cache->warm());
                }
            });
        }
    }
}
