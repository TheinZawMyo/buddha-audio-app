<?php

return [
    'audio_disk' => env('CATALOG_AUDIO_DISK', 'static'),
    'cover_disk' => env('CATALOG_COVER_DISK', 'static'),

    'nginx_media' => [
        'enabled' => (bool) env('CATALOG_NGINX_MEDIA_ENABLED', false),
        'internal_prefix' => env('CATALOG_NGINX_MEDIA_INTERNAL_PREFIX', '/_protected_media'),
    ],

    'playback_url_ttl' => (int) env('CATALOG_PLAYBACK_URL_TTL', 30),

    'audio_max_bytes' => (int) env('CATALOG_AUDIO_MAX_BYTES', 512000 * 1024),

    'per_page' => (int) env('CATALOG_PER_PAGE', 15),

    'cache' => [
        'store' => env('CATALOG_CACHE_STORE', env('CACHE_STORE', 'redis')),
        'ttl' => (int) env('CATALOG_CACHE_TTL', 300),
    ],

    'home' => [
        'featured_limit' => (int) env('CATALOG_HOME_FEATURED_LIMIT', 4),
        'latest_limit' => (int) env('CATALOG_HOME_LATEST_LIMIT', 8),
    ],
];
