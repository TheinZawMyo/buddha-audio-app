<?php

namespace App\Http\Middleware;

use App\Models\ApiKey;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Symfony\Component\HttpFoundation\Response;

class EnsureValidApiKey
{
    /**
     * Handle an incoming request.
     *
     * @param  Closure(Request): (Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $plainTextKey = $request->header('X-API-Key');

        if (! is_string($plainTextKey) || ! preg_match('/^dw_live_[a-f0-9]{64}$/', $plainTextKey)) {
            return $this->unauthorized($request);
        }

        $keyPrefix = substr($plainTextKey, 0, 24);
        $apiKey = ApiKey::query()->where('key_prefix', $keyPrefix)->first();

        if (
            $apiKey === null ||
            ! hash_equals($apiKey->key_hash, hash('sha256', $plainTextKey)) ||
            ! $apiKey->is_active ||
            ($apiKey->expires_at !== null && $apiKey->expires_at->isPast())
        ) {
            return $this->unauthorized($request);
        }

        $rateLimitKey = 'api-key:'.$apiKey->getKey();

        if (RateLimiter::tooManyAttempts($rateLimitKey, $apiKey->rate_limit_per_minute)) {
            $retryAfter = RateLimiter::availableIn($rateLimitKey);

            return response()->json(
                ['message' => 'Too many requests.'],
                429,
                ['Retry-After' => (string) $retryAfter],
            );
        }

        RateLimiter::hit($rateLimitKey, 60);

        if ($apiKey->last_used_at === null || $apiKey->last_used_at->lt(now()->subMinute())) {
            $apiKey->forceFill(['last_used_at' => now()])->save();
        }

        return $next($request);
    }

    private function unauthorized(Request $request): Response
    {
        $rateLimitKey = 'invalid-api-key:'.$request->ip();

        if (RateLimiter::tooManyAttempts($rateLimitKey, 30)) {
            $retryAfter = RateLimiter::availableIn($rateLimitKey);

            return response()->json(
                ['message' => 'Too many requests.'],
                429,
                ['Retry-After' => (string) $retryAfter],
            );
        }

        RateLimiter::hit($rateLimitKey, 60);

        return response()->json(['message' => 'Unauthenticated.'], 401);
    }
}
