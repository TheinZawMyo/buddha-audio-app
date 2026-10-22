<?php

namespace App\Models;

use Database\Factories\TeacherFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Attributes\RouteKey;
use Illuminate\Database\Eloquent\Attributes\Scope;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\Storage;

#[Fillable(['name', 'short_name', 'slug', 'bio', 'photo_path', 'photo_url', 'sort_order', 'is_active'])]
#[RouteKey('slug')]
class Teacher extends Model
{
    /** @use HasFactory<TeacherFactory> */
    use HasFactory, HasUuids, SoftDeletes;

    /**
     * @var list<string>
     */
    protected $appends = ['photo_url'];

    /**
     * Resolve the public photo URL from an upload or an external URL.
     */
    protected function photoUrl(): Attribute
    {
        return Attribute::get(fn (?string $value): ?string => $value ?: ($this->photo_path ? Storage::disk('public')->url($this->photo_path) : null));
    }

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'sort_order' => 'integer',
            'is_active' => 'boolean',
        ];
    }

    /**
     * @return HasMany<Audio, $this>
     */
    public function audios(): HasMany
    {
        return $this->hasMany(Audio::class);
    }

    #[Scope]
    protected function active(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }

    #[Scope]
    protected function ordered(Builder $query): Builder
    {
        return $query->orderBy('sort_order')->orderBy('name');
    }
}
