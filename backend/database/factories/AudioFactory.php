<?php

namespace Database\Factories;

use App\Enums\AudioStatus;
use App\Models\Audio;
use App\Models\AudioType;
use App\Models\Teacher;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Audio>
 */
class AudioFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'teacher_id' => Teacher::factory(),
            'audio_type_id' => AudioType::factory(),
            'title' => fake()->sentence(4),
            'slug' => fake()->unique()->slug(4),
            'description' => fake()->paragraph(),
            'language' => 'my',
            'duration_seconds' => fake()->numberBetween(120, 1800),
            'status' => AudioStatus::Draft,
            'published_at' => null,
            'external_playback_url' => fake()->url().'.mp3',
            'created_by' => null,
            'updated_by' => null,
        ];
    }

    /**
     * Indicate that the audio is published.
     */
    public function published(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => AudioStatus::Published,
            'published_at' => now()->subDay(),
        ]);
    }

    /**
     * Indicate that the audio is archived.
     */
    public function archived(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => AudioStatus::Archived,
        ]);
    }
}
