<?php

namespace Tests\Feature;

use App\Models\AudioCategory;
use App\Models\AudioType;
use App\Models\Teacher;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class AdminCatalogTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = User::factory()->admin()->create();
        Storage::fake(config('catalog.cover_disk'));
    }

    public function test_teacher_is_created_with_photo_and_audit_log(): void
    {
        $response = $this->actingAs($this->admin)->post(route('admin.teachers.store'), [
            'name' => 'Sayadaw Nanda',
            'short_name' => 'Nanda',
            'slug' => 'sayadaw-nanda',
            'bio' => 'Dhamma teacher.',
            'photo' => UploadedFile::fake()->image('teacher.jpg', 240, 240),
            'sort_order' => 1,
            'is_active' => true,
        ]);

        $response->assertRedirect(route('admin.teachers.edit', 'sayadaw-nanda'))
            ->assertSessionHasNoErrors();

        $teacher = Teacher::query()->where('slug', 'sayadaw-nanda')->firstOrFail();

        $this->assertSame('Sayadaw Nanda', $teacher->name);
        $this->assertTrue($teacher->is_active);
        $this->assertNotNull($teacher->photo_path);
        Storage::disk(config('catalog.cover_disk'))->assertExists($teacher->photo_path);

        $this->assertDatabaseHas('audit_logs', [
            'action' => 'created',
            'auditable_type' => Teacher::class,
            'auditable_id' => $teacher->id,
            'user_id' => $this->admin->id,
        ]);
    }

    public function test_teacher_requires_a_name(): void
    {
        $this->actingAs($this->admin)
            ->post(route('admin.teachers.store'), [])
            ->assertSessionHasErrors('name');

        $this->assertDatabaseCount('teachers', 0);
    }

    public function test_teacher_can_be_updated_and_slug_is_kept_unique(): void
    {
        $teacher = Teacher::factory()->create(['slug' => 'teacher-one', 'name' => 'Teacher One']);

        $this->actingAs($this->admin)
            ->put(route('admin.teachers.update', $teacher->slug), [
                'name' => 'Teacher One Updated',
                'short_name' => 'One',
                'slug' => 'teacher-one',
                'bio' => 'Updated bio.',
                'sort_order' => 2,
                'is_active' => false,
            ])
            ->assertSessionHasNoErrors();

        $teacher->refresh();

        $this->assertSame('Teacher One Updated', $teacher->name);
        $this->assertFalse($teacher->is_active);
        $this->assertDatabaseHas('audit_logs', ['action' => 'updated', 'auditable_id' => $teacher->id]);
    }

    public function test_teacher_can_be_soft_deleted(): void
    {
        $teacher = Teacher::factory()->create();

        $this->actingAs($this->admin)
            ->delete(route('admin.teachers.destroy', $teacher->slug))
            ->assertRedirect(route('admin.teachers.index'));

        $this->assertSoftDeleted('teachers', ['id' => $teacher->id]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'deleted', 'auditable_id' => $teacher->id]);
    }

    public function test_category_and_audio_type_can_be_managed(): void
    {
        $this->actingAs($this->admin)
            ->post(route('admin.categories.store'), [
                'name' => 'Dhamma Talks',
                'slug' => 'dhamma-talks',
                'sort_order' => 1,
                'is_active' => true,
            ])
            ->assertRedirect();

        $this->actingAs($this->admin)
            ->post(route('admin.audio-types.store'), [
                'name' => 'Chanting',
                'slug' => 'chanting',
                'sort_order' => 2,
                'is_active' => true,
            ])
            ->assertRedirect();

        $category = AudioCategory::query()->where('slug', 'dhamma-talks')->firstOrFail();
        $type = AudioType::query()->where('slug', 'chanting')->firstOrFail();

        $this->assertTrue($category->is_active);
        $this->assertTrue($type->is_active);

        $this->actingAs($this->admin)
            ->put(route('admin.categories.update', $category->slug), [
                'name' => 'Dhamma Talks Updated',
                'slug' => 'dhamma-talks',
                'sort_order' => 3,
                'is_active' => false,
            ])
            ->assertSessionHasNoErrors();

        $this->assertSame('Dhamma Talks Updated', $category->refresh()->name);
        $this->assertFalse($category->is_active);
    }
}
