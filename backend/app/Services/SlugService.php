<?php

namespace App\Services;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class SlugService
{
    /**
     * @param  class-string<Model>  $modelClass
     */
    public function uniqueFor(string $modelClass, string $name, ?string $ignoreId = null): string
    {
        $base = Str::slug($name);

        if ($base === '') {
            $base = 'item-'.Str::lower(Str::random(8));
        }

        $slug = $base;
        $suffix = 2;

        while ($this->slugExists($modelClass, $slug, $ignoreId)) {
            $slug = $base.'-'.$suffix;
            $suffix++;
        }

        return $slug;
    }

    /**
     * @param  class-string<Model>  $modelClass
     */
    public function resolve(string $modelClass, ?string $slug, string $name, ?string $ignoreId = null): string
    {
        if (filled($slug)) {
            return $this->uniqueFor($modelClass, (string) $slug, $ignoreId);
        }

        return $this->uniqueFor($modelClass, $name, $ignoreId);
    }

    /**
     * @param  class-string<Model>  $modelClass
     */
    private function slugExists(string $modelClass, string $slug, ?string $ignoreId): bool
    {
        return $modelClass::query()
            ->withTrashed()
            ->where('slug', $slug)
            ->when($ignoreId, fn ($query) => $query->whereKeyNot($ignoreId))
            ->exists();
    }
}
