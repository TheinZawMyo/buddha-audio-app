<?php

return [
    'audio_disk' => env('CATALOG_AUDIO_DISK', 'local'),
    'cover_disk' => env('CATALOG_COVER_DISK', 'public'),

    'playback_url_ttl' => (int) env('CATALOG_PLAYBACK_URL_TTL', 30),

    'per_page' => (int) env('CATALOG_PER_PAGE', 15),

    'home' => [
        'featured_limit' => (int) env('CATALOG_HOME_FEATURED_LIMIT', 4),
        'latest_limit' => (int) env('CATALOG_HOME_LATEST_LIMIT', 8),
    ],
];
