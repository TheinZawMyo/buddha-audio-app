<?php

namespace Database\Factories;

use App\Models\AudioCategory;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<AudioCategory>
 */
class AudioCategoryFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->unique()->words(2, true),
            'slug' => fake()->unique()->slug(2),
            'description' => fake()->sentence(),
            'sort_order' => fake()->numberBetween(0, 20),
            'is_active' => true,
        ];
    }

    /**
     * Indicate that the category is hidden from the public catalog.
     */
    public function inactive(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => false,
        ]);
    }
}
