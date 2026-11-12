<?php

namespace Tests\Feature;

use App\Models\Audio;
use App\Models\FeaturedAudio;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminFeaturedAudioTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = User::factory()->admin()->create();
    }

    public function test_featured_audio_can_be_created_and_audited(): void
    {
        $audio = Audio::factory()->published()->create();

        $this->actingAs($this->admin)
            ->post(route('admin.featured-audios.store'), [
                'audio_id' => $audio->id,
                'sort_order' => 3,
                'is_active' => true,
            ])
            ->assertRedirect(route('admin.featured-audios.index'))
            ->assertSessionHasNoErrors();

        $this->assertDatabaseHas('featured_audios', [
            'audio_id' => $audio->id,
            'sort_order' => 3,
            'is_active' => true,
        ]);

        $featured = FeaturedAudio::query()->where('audio_id', $audio->id)->firstOrFail();

        $this->assertDatabaseHas('audit_logs', [
            'action' => 'created',
            'auditable_type' => FeaturedAudio::class,
            'auditable_id' => $featured->id,
            'user_id' => $this->admin->id,
        ]);
    }

    public function test_only_published_audio_can_be_featured(): void
    {
        $draft = Audio::factory()->create();

        $this->actingAs($this->admin)
            ->post(route('admin.featured-audios.store'), [
                'audio_id' => $draft->id,
                'sort_order' => 1,
                'is_active' => true,
            ])
            ->assertSessionHasErrors('audio_id');

        $this->assertDatabaseCount('featured_audios', 0);
    }

    public function test_audio_cannot_be_featured_twice(): void
    {
        $audio = Audio::factory()->published()->create();
        FeaturedAudio::factory()->create(['audio_id' => $audio->id]);

        $this->actingAs($this->admin)
            ->post(route('admin.featured-audios.store'), [
                'audio_id' => $audio->id,
                'sort_order' => 2,
                'is_active' => true,
            ])
            ->assertSessionHasErrors('audio_id');
    }

    public function test_featured_audio_can_be_updated(): void
    {
        $featured = FeaturedAudio::factory()->create([
            'audio_id' => Audio::factory()->published()->create()->id,
            'sort_order' => 1,
            'is_active' => true,
        ]);

        $this->actingAs($this->admin)
            ->put(route('admin.featured-audios.update', $featured), [
                'audio_id' => $featured->audio_id,
                'sort_order' => 9,
                'is_active' => false,
            ])
            ->assertRedirect(route('admin.featured-audios.index'))
            ->assertSessionHasNoErrors();

        $featured->refresh();

        $this->assertSame(9, $featured->sort_order);
        $this->assertFalse($featured->is_active);
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'updated',
            'auditable_type' => FeaturedAudio::class,
            'auditable_id' => $featured->id,
        ]);
    }

    public function test_featured_audio_can_be_deleted(): void
    {
        $featured = FeaturedAudio::factory()->create();

        $this->actingAs($this->admin)
            ->delete(route('admin.featured-audios.destroy', $featured))
            ->assertRedirect(route('admin.featured-audios.index'));

        $this->assertDatabaseMissing('featured_audios', ['id' => $featured->id]);
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'deleted',
            'auditable_type' => FeaturedAudio::class,
            'auditable_id' => $featured->id,
        ]);
    }
}
