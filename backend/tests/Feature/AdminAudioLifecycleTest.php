<?php

namespace Tests\Feature;

use App\Enums\AudioStatus;
use App\Models\Audio;
use App\Models\AudioCategory;
use App\Models\AudioType;
use App\Models\Teacher;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class AdminAudioLifecycleTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = User::factory()->admin()->create();
        Storage::fake(config('catalog.audio_disk'));
        Storage::fake(config('catalog.cover_disk'));
    }

    public function test_audio_is_created_as_draft_with_categories_and_audit_log(): void
    {
        $teacher = Teacher::factory()->create();
        $type = AudioType::factory()->create();
        $category = AudioCategory::factory()->create();

        $response = $this->actingAs($this->admin)->post(route('admin.audios.store'), [
            'title' => 'Mind of Peace',
            'slug' => 'mind-of-peace',
            'description' => 'A talk about calm.',
            'teacher_id' => $teacher->id,
            'audio_type_id' => $type->id,
            'categories' => [$category->id],
            'language' => 'my',
            'duration_seconds' => 372,
            'external_playback_url' => 'https://cdn.example.com/mind-of-peace.mp3',
        ]);

        $response->assertRedirect(route('admin.audios.edit', 'mind-of-peace'))
            ->assertSessionHasNoErrors();

        $audio = Audio::query()->where('slug', 'mind-of-peace')->firstOrFail();

        $this->assertSame(AudioStatus::Draft, $audio->status);
        $this->assertNull($audio->published_at);
        $this->assertSame($this->admin->id, $audio->created_by);
        $this->assertTrue($audio->categories->contains($category));
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'created',
            'auditable_type' => Audio::class,
            'auditable_id' => $audio->id,
        ]);
    }

    public function test_audio_requires_title_teacher_and_type(): void
    {
        $this->actingAs($this->admin)
            ->post(route('admin.audios.store'), [])
            ->assertSessionHasErrors(['title', 'teacher_id', 'audio_type_id', 'language', 'duration_seconds']);

        $this->assertDatabaseCount('audios', 0);
    }

    public function test_audio_rejects_unsupported_file_types(): void
    {
        $teacher = Teacher::factory()->create();
        $type = AudioType::factory()->create();

        $this->actingAs($this->admin)
            ->post(route('admin.audios.store'), [
                'title' => 'Bad file',
                'teacher_id' => $teacher->id,
                'audio_type_id' => $type->id,
                'language' => 'my',
                'duration_seconds' => 10,
                'audio_file' => UploadedFile::fake()->create('notes.pdf', 10, 'application/pdf'),
            ])
            ->assertSessionHasErrors('audio_file');

        $this->assertDatabaseCount('audios', 0);
    }

    public function test_publish_requires_a_playable_asset(): void
    {
        $audio = Audio::factory()->create([
            'audio_path' => null,
            'external_playback_url' => null,
            'duration_seconds' => 120,
        ]);

        $this->actingAs($this->admin)
            ->post(route('admin.audios.publish', $audio->slug))
            ->assertSessionHasErrors('publish');

        $this->assertSame(AudioStatus::Draft, $audio->refresh()->status);
    }

    public function test_publish_requires_a_positive_duration(): void
    {
        $audio = Audio::factory()->create([
            'external_playback_url' => 'https://cdn.example.com/talk.mp3',
            'duration_seconds' => 0,
        ]);

        $this->actingAs($this->admin)
            ->post(route('admin.audios.publish', $audio->slug))
            ->assertSessionHasErrors('publish');

        $this->assertSame(AudioStatus::Draft, $audio->refresh()->status);
    }

    public function test_published_audio_is_visible_on_the_public_api(): void
    {
        $audio = Audio::factory()->create([
            'slug' => 'ready-to-publish',
            'external_playback_url' => 'https://cdn.example.com/talk.mp3',
            'duration_seconds' => 120,
        ]);

        $this->actingAs($this->admin)
            ->post(route('admin.audios.publish', $audio->slug))
            ->assertSessionHasNoErrors();

        $audio->refresh();

        $this->assertSame(AudioStatus::Published, $audio->status);
        $this->assertNotNull($audio->published_at);
        $this->assertDatabaseHas('audit_logs', ['action' => 'published', 'auditable_id' => $audio->id]);

        $this->getJson('/api/v1/audios/'.$audio->slug)
            ->assertOk()
            ->assertJsonPath('data.slug', 'ready-to-publish');
    }

    public function test_archiving_hides_audio_from_the_public_api(): void
    {
        $audio = Audio::factory()->published()->create(['slug' => 'published-audio']);

        $this->actingAs($this->admin)
            ->post(route('admin.audios.archive', $audio->slug))
            ->assertSessionHasNoErrors();

        $this->assertSame(AudioStatus::Archived, $audio->refresh()->status);
        $this->assertDatabaseHas('audit_logs', ['action' => 'archived', 'auditable_id' => $audio->id]);

        $this->getJson('/api/v1/audios/'.$audio->slug)->assertNotFound();
    }

    public function test_audio_metadata_and_categories_can_be_updated(): void
    {
        $audio = Audio::factory()->published()->create(['slug' => 'editable-audio']);
        $category = AudioCategory::factory()->create();
        $teacher = Teacher::factory()->create();
        $type = AudioType::factory()->create();

        $this->actingAs($this->admin)
            ->put(route('admin.audios.update', $audio->slug), [
                'title' => 'Updated Title',
                'slug' => 'editable-audio',
                'description' => 'Updated description.',
                'teacher_id' => $teacher->id,
                'audio_type_id' => $type->id,
                'categories' => [$category->id],
                'language' => 'my',
                'duration_seconds' => 400,
                'external_playback_url' => 'https://cdn.example.com/updated.mp3',
            ])
            ->assertSessionHasNoErrors();

        $audio->refresh();

        $this->assertSame('Updated Title', $audio->title);
        $this->assertSame(400, $audio->duration_seconds);
        $this->assertTrue($audio->categories->contains($category));
        $this->assertSame(AudioStatus::Published, $audio->status);
        $this->assertDatabaseHas('audit_logs', ['action' => 'updated', 'auditable_id' => $audio->id]);
    }

    public function test_audio_delete_soft_deletes_and_hides_the_record(): void
    {
        $audio = Audio::factory()->published()->create(['slug' => 'deletable-audio']);

        $this->actingAs($this->admin)
            ->delete(route('admin.audios.destroy', $audio->slug))
            ->assertRedirect(route('admin.audios.index'));

        $this->assertSoftDeleted('audios', ['id' => $audio->id]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'deleted', 'auditable_id' => $audio->id]);
        $this->getJson('/api/v1/audios/'.$audio->slug)->assertNotFound();
    }

    public function test_uploaded_audio_is_stored_and_streamed_after_publish(): void
    {
        $teacher = Teacher::factory()->create();
        $type = AudioType::factory()->create();

        $this->actingAs($this->admin)
            ->post(route('admin.audios.store'), [
                'title' => 'Uploaded Talk',
                'slug' => 'uploaded-talk',
                'teacher_id' => $teacher->id,
                'audio_type_id' => $type->id,
                'language' => 'my',
                'duration_seconds' => 90,
                'audio_file' => UploadedFile::fake()->create('talk.mp3', 100, 'audio/mpeg'),
            ])
            ->assertSessionHasNoErrors();

        $audio = Audio::query()->where('slug', 'uploaded-talk')->firstOrFail();

        $this->assertNotNull($audio->audio_path);
        $this->assertSame('talk.mp3', $audio->audio_original_name);
        Storage::disk(config('catalog.audio_disk'))->assertExists($audio->audio_path);

        $this->actingAs($this->admin)
            ->post(route('admin.audios.publish', $audio->slug))
            ->assertSessionHasNoErrors();

        $this->get($audio->refresh()->playback_url)->assertOk();
    }
}
