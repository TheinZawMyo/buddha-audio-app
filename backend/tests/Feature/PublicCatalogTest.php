<?php

namespace Tests\Feature;

use App\Models\Audio;
use App\Models\AudioCategory;
use App\Models\AudioType;
use App\Models\FeaturedAudio;
use App\Models\Teacher;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class PublicCatalogTest extends TestCase
{
    use RefreshDatabase;

    public function test_home_returns_only_published_audio_and_active_taxonomy(): void
    {
        $teacher = Teacher::factory()->create(['slug' => 'active-teacher']);
        Teacher::factory()->inactive()->create();

        $category = AudioCategory::factory()->create(['slug' => 'active-category']);
        AudioCategory::factory()->inactive()->create();

        $type = AudioType::factory()->create(['slug' => 'active-type']);
        AudioType::factory()->inactive()->create();

        $published = Audio::factory()->published()->create([
            'teacher_id' => $teacher->id,
            'audio_type_id' => $type->id,
            'slug' => 'published-talk',
            'title' => 'Published Talk',
        ]);
        $published->categories()->attach($category);

        Audio::factory()->create(['teacher_id' => $teacher->id, 'audio_type_id' => $type->id]);
        Audio::factory()->archived()->create(['teacher_id' => $teacher->id, 'audio_type_id' => $type->id]);

        $response = $this->getJson('/api/v1/home');

        $response->assertOk()
            ->assertJsonCount(1, 'data.latest')
            ->assertJsonCount(1, 'data.featured')
            ->assertJsonPath('data.latest.0.slug', 'published-talk')
            ->assertJsonCount(1, 'data.teachers')
            ->assertJsonPath('data.teachers.0.slug', 'active-teacher')
            ->assertJsonCount(1, 'data.categories')
            ->assertJsonPath('data.categories.0.slug', 'active-category')
            ->assertJsonCount(1, 'data.audio_types')
            ->assertJsonPath('data.audio_types.0.slug', 'active-type');
    }

    public function test_home_uses_custom_featured_list_order_and_visibility(): void
    {
        $featuredFirst = Audio::factory()->published()->create([
            'slug' => 'curated-first',
            'published_at' => now()->subDays(10),
        ]);
        $featuredSecond = Audio::factory()->published()->create([
            'slug' => 'curated-second',
            'published_at' => now()->subDays(5),
        ]);
        $hidden = Audio::factory()->published()->create(['slug' => 'curated-hidden']);
        $draft = Audio::factory()->create(['slug' => 'curated-draft']);

        FeaturedAudio::factory()->create(['audio_id' => $featuredSecond->id, 'sort_order' => 2]);
        FeaturedAudio::factory()->create(['audio_id' => $featuredFirst->id, 'sort_order' => 1]);
        FeaturedAudio::factory()->inactive()->create(['audio_id' => $hidden->id, 'sort_order' => 0]);
        FeaturedAudio::factory()->create(['audio_id' => $draft->id, 'sort_order' => 0]);

        $this->getJson('/api/v1/home')
            ->assertOk()
            ->assertJsonCount(2, 'data.featured')
            ->assertJsonPath('data.featured.0.slug', 'curated-first')
            ->assertJsonPath('data.featured.1.slug', 'curated-second');
    }

    public function test_audio_list_filters_by_query_teacher_category_and_type(): void
    {
        $teacherA = Teacher::factory()->create(['slug' => 'teacher-a', 'name' => 'Teacher A']);
        $teacherB = Teacher::factory()->create(['slug' => 'teacher-b', 'name' => 'Teacher B']);
        $typeA = AudioType::factory()->create(['slug' => 'type-a']);
        $typeB = AudioType::factory()->create(['slug' => 'type-b']);
        $categoryA = AudioCategory::factory()->create(['slug' => 'category-a']);
        $categoryB = AudioCategory::factory()->create(['slug' => 'category-b']);

        $audioA = Audio::factory()->published()->create([
            'teacher_id' => $teacherA->id,
            'audio_type_id' => $typeA->id,
            'title' => 'Loving Kindness',
            'slug' => 'audio-a',
        ]);
        $audioA->categories()->attach($categoryA);

        $audioB = Audio::factory()->published()->create([
            'teacher_id' => $teacherB->id,
            'audio_type_id' => $typeB->id,
            'title' => 'Evening Chanting',
            'slug' => 'audio-b',
        ]);
        $audioB->categories()->attach($categoryB);

        $this->getJson('/api/v1/audios?query=Loving')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.slug', 'audio-a');

        $this->getJson('/api/v1/audios?teacher=teacher-b')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.slug', 'audio-b');

        $this->getJson('/api/v1/audios?category=category-a')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.slug', 'audio-a');

        $this->getJson('/api/v1/audios?type=type-b')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.slug', 'audio-b');
    }

    public function test_audio_list_uses_cursor_pagination(): void
    {
        Audio::factory()->published()->count(3)->create();

        $firstPage = $this->getJson('/api/v1/audios?limit=2');

        $firstPage->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('meta.pagination.has_more', true)
            ->assertJsonPath('meta.pagination.total', 3);

        $cursor = $firstPage->json('meta.pagination.next_cursor');

        $this->getJson('/api/v1/audios?limit=2&cursor='.urlencode($cursor))
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('meta.pagination.has_more', false);
    }

    public function test_audio_detail_returns_relationship_payload(): void
    {
        $category = AudioCategory::factory()->create(['slug' => 'dhamma-talks']);
        $audio = Audio::factory()->published()->create(['slug' => 'mind-of-peace', 'duration_seconds' => 372]);
        $audio->categories()->attach($category);

        $this->getJson('/api/v1/audios/mind-of-peace')
            ->assertOk()
            ->assertJsonPath('data.slug', 'mind-of-peace')
            ->assertJsonPath('data.duration_seconds', 372)
            ->assertJsonPath('data.categories.0.slug', 'dhamma-talks')
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'slug',
                    'title',
                    'teacher' => ['id', 'slug', 'name'],
                    'type' => ['id', 'slug', 'name'],
                    'categories',
                    'playback_url',
                    'published_at',
                ],
            ]);
    }

    public function test_draft_and_archived_audio_are_not_public(): void
    {
        $draft = Audio::factory()->create(['slug' => 'draft-audio']);
        $archived = Audio::factory()->archived()->create(['slug' => 'archived-audio']);

        $this->getJson('/api/v1/audios/'.$draft->slug)->assertNotFound();
        $this->getJson('/api/v1/audios/'.$archived->slug)->assertNotFound();

        $this->getJson('/api/v1/audios')
            ->assertOk()
            ->assertJsonCount(0, 'data');
    }

    public function test_playback_url_returns_external_url(): void
    {
        $audio = Audio::factory()->published()->create([
            'slug' => 'external-audio',
            'external_playback_url' => 'https://cdn.example.com/talk.mp3',
        ]);

        $this->postJson('/api/v1/audios/'.$audio->slug.'/playback-url')
            ->assertOk()
            ->assertJsonPath('data.playback_url', 'https://cdn.example.com/talk.mp3');
    }

    public function test_signed_stream_serves_private_upload(): void
    {
        Storage::fake(config('catalog.audio_disk'));
        Storage::disk(config('catalog.audio_disk'))->put('audio/talk.mp3', 'fake-audio-bytes');

        $audio = Audio::factory()->published()->create([
            'slug' => 'private-audio',
            'audio_path' => 'audio/talk.mp3',
            'external_playback_url' => null,
            'audio_mime' => 'audio/mpeg',
            'duration_seconds' => 120,
        ]);

        $this->get($audio->playback_url)->assertOk();

        $this->get(route('api.v1.audios.stream', $audio->slug))->assertForbidden();
    }

    public function test_media_route_serves_audio_files(): void
    {
        Storage::fake(config('catalog.audio_disk'));
        Storage::disk(config('catalog.audio_disk'))->put('audio/test.mp3', 'fake-audio-bytes');

        $this->get('/api/v1/media/audio/test.mp3')
            ->assertOk()
            ->assertHeader('Content-Type');
    }

    public function test_media_route_rejects_unknown_directories(): void
    {
        $this->get('/api/v1/media/private/test.mp3')->assertNotFound();
    }

    public function test_inactive_teacher_is_not_public(): void
    {
        $teacher = Teacher::factory()->inactive()->create(['slug' => 'hidden-teacher']);

        $this->getJson('/api/v1/teachers/hidden-teacher')->assertNotFound();

        $this->getJson('/api/v1/teachers')
            ->assertOk()
            ->assertJsonCount(0, 'data');
    }

    public function test_api_responses_are_cached_and_invalidated_on_catalog_changes(): void
    {
        $audio = Audio::factory()->published()->create([
            'slug' => 'cached-audio',
            'title' => 'Cached Title',
        ]);

        $this->getJson('/api/v1/audios/cached-audio')
            ->assertOk()
            ->assertJsonPath('data.title', 'Cached Title');

        DB::table('audios')->where('id', $audio->id)->update(['title' => 'Changed Outside Eloquent']);

        $this->getJson('/api/v1/audios/cached-audio')
            ->assertOk()
            ->assertJsonPath('data.title', 'Cached Title');

        $audio->update(['title' => 'Updated Through Eloquent']);

        $this->getJson('/api/v1/audios/cached-audio')
            ->assertOk()
            ->assertJsonPath('data.title', 'Updated Through Eloquent');
    }
}
