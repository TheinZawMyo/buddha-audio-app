<?php

return [
    'audio_disk' => env('CATALOG_AUDIO_DISK', 'static'),
    'cover_disk' => env('CATALOG_COVER_DISK', 'static'),

    'playback_url_ttl' => (int) env('CATALOG_PLAYBACK_URL_TTL', 30),

    'audio_max_bytes' => (int) env('CATALOG_AUDIO_MAX_BYTES', 512000 * 1024),

    'per_page' => (int) env('CATALOG_PER_PAGE', 15),

    'home' => [
        'featured_limit' => (int) env('CATALOG_HOME_FEATURED_LIMIT', 4),
        'latest_limit' => (int) env('CATALOG_HOME_LATEST_LIMIT', 8),
    ],
];
