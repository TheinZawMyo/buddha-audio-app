<?php

namespace App\Models;

use App\Enums\AudioStatus;
use Database\Factories\AudioFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Attributes\RouteKey;
use Illuminate\Database\Eloquent\Attributes\Scope;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\URL;

#[Fillable([
    'teacher_id',
    'audio_type_id',
    'title',
    'slug',
    'description',
    'language',
    'duration_seconds',
    'status',
    'published_at',
    'audio_path',
    'audio_original_name',
    'audio_mime',
    'audio_size',
    'external_playback_url',
    'cover_path',
    'cover_url',
    'created_by',
    'updated_by',
])]
#[RouteKey('slug')]
#[Table('audios')]
class Audio extends Model
{
    /** @use HasFactory<AudioFactory> */
    use HasFactory, HasUuids, SoftDeletes;

    /**
     * @var list<string>
     */
    protected $appends = ['playback_url', 'cover_image_url'];

    /**
     * Resolve a short-lived signed stream URL or the configured external URL.
     */
    protected function playbackUrl(): Attribute
    {
        return Attribute::get(function (): ?string {
            if (filled($this->external_playback_url)) {
                return $this->external_playback_url;
            }

            if (! filled($this->audio_path)) {
                return null;
            }

            return URL::temporarySignedRoute(
                'api.v1.audios.stream',
                now()->addMinutes((int) config('catalog.playback_url_ttl', 30)),
                ['audio' => $this->slug],
            );
        });
    }

    protected function coverImageUrl(): Attribute
    {
        return Attribute::get(fn (): ?string => $this->cover_url
            ?: ($this->cover_path ? Storage::disk('public')->url($this->cover_path) : null));
    }

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'status' => AudioStatus::class,
            'published_at' => 'datetime',
            'duration_seconds' => 'integer',
            'audio_size' => 'integer',
        ];
    }

    /**
     * @return BelongsTo<Teacher, $this>
     */
    public function teacher(): BelongsTo
    {
        return $this->belongsTo(Teacher::class);
    }

    /**
     * @return BelongsTo<AudioType, $this>
     */
    public function audioType(): BelongsTo
    {
        return $this->belongsTo(AudioType::class);
    }

    /**
     * @return BelongsToMany<AudioCategory, $this>
     */
    public function categories(): BelongsToMany
    {
        return $this->belongsToMany(AudioCategory::class, 'audio_audio_category');
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function updater(): BelongsTo
    {
        return $this->belongsTo(User::class, 'updated_by');
    }

    public function hasPlayableAsset(): bool
    {
        return filled($this->audio_path) || filled($this->external_playback_url);
    }

    #[Scope]
    protected function published(Builder $query): Builder
    {
        return $query->where('status', AudioStatus::Published->value);
    }

    #[Scope]
    protected function withCatalog(Builder $query): Builder
    {
        return $query->with(['teacher', 'audioType', 'categories']);
    }
}
