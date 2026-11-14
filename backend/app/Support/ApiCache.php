<?php

namespace App\Support;

use Closure;
use Illuminate\Contracts\Cache\Repository;
use Illuminate\Support\Facades\Cache;

class ApiCache
{
    private const VERSION_KEY = 'catalog:api:version';

    /**
     * Resolve a value from the cache, falling back to the database callback.
     */
    public function remember(string $key, Closure $callback): mixed
    {
        return $this->store()->remember($this->versionedKey($key), $this->ttl(), $callback);
    }

    /**
     * Invalidate every cached API response by rotating the cache version.
     */
    public function flush(): void
    {
        $store = $this->store();

        $store->forever(self::VERSION_KEY, $this->version($store) + 1);
    }

    private function versionedKey(string $key): string
    {
        return 'catalog:api:v'.$this->version($this->store()).':'.$key;
    }

    private function version(Repository $store): int
    {
        return (int) $store->get(self::VERSION_KEY, 1);
    }

    private function ttl(): int
    {
        return (int) config('catalog.cache.ttl', 300);
    }

    private function store(): Repository
    {
        return Cache::store((string) config('catalog.cache.store', 'redis'));
    }
}
