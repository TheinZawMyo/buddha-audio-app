<?php

namespace Database\Factories;

use App\Models\Audio;
use App\Models\FeaturedAudio;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<FeaturedAudio>
 */
class FeaturedAudioFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'audio_id' => Audio::factory(),
            'sort_order' => fake()->numberBetween(0, 20),
            'is_active' => true,
        ];
    }

    /**
     * Indicate that the featured entry is hidden from the home page.
     */
    public function inactive(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => false,
        ]);
    }
}
