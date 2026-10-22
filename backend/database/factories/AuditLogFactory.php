<?php

namespace Database\Factories;

use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<AuditLog>
 */
class AuditLogFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'action' => fake()->randomElement(['created', 'updated', 'published', 'archived', 'deleted']),
            'auditable_type' => null,
            'auditable_id' => null,
            'description' => fake()->sentence(),
            'changes' => [],
            'ip_address' => fake()->ipv4(),
        ];
    }
}
