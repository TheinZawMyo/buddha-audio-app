<?php

namespace Database\Factories;

use App\Models\ApiKey;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<ApiKey>
 */
class ApiKeyFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $secret = 'dw_live_'.bin2hex(random_bytes(32));

        return [
            'name' => fake()->words(2, true),
            'key_prefix' => substr($secret, 0, 24),
            'key_hash' => hash('sha256', $secret),
            'is_active' => true,
            'rate_limit_per_minute' => 300,
            'expires_at' => null,
            'last_used_at' => null,
            'created_by' => null,
        ];
    }
}
