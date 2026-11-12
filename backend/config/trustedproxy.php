<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Trusted Proxies
    |--------------------------------------------------------------------------
    |
    | Proxies listed here are trusted to provide the client IP address through
    | the X-Forwarded-* headers. Use "*" to trust any proxy (local development
    | or a managed load balancer), or a comma-separated list of proxy IPs.
    |
    */

    'proxies' => env('TRUSTED_PROXIES', '*'),

];
