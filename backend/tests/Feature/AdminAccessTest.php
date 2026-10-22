<?php

namespace Tests\Feature;

use App\Models\Audio;
use App\Models\AudioCategory;
use App\Models\AudioType;
use App\Models\Teacher;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Inertia\Testing\AssertableInertia as Assert;
use Tests\TestCase;

class AdminAccessTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_is_redirected_to_login(): void
    {
        $this->get('/admin')->assertRedirect('/login');
    }

    public function test_inactive_user_is_logged_out_and_redirected(): void
    {
        $user = User::factory()->inactive()->create();

        $this->actingAs($user)
            ->get('/admin')
            ->assertRedirect('/login');

        $this->assertGuest();
    }

    public function test_active_user_can_view_dashboard(): void
    {
        $user = User::factory()->admin()->create();
        $teacher = Teacher::factory()->create();
        $type = AudioType::factory()->create();
        AudioCategory::factory()->create();

        Audio::factory()->published()->count(2)->create([
            'teacher_id' => $teacher->id,
            'audio_type_id' => $type->id,
        ]);
        Audio::factory()->create([
            'teacher_id' => $teacher->id,
            'audio_type_id' => $type->id,
        ]);

        $this->actingAs($user)
            ->get('/admin')
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->component('Admin/Dashboard')
                ->where('statusCounts.published', 2)
                ->where('statusCounts.draft', 1)
                ->where('teacherCount', 1)
                ->where('categoryCount', 1)
                ->where('typeCount', 1)
                ->has('recentAudios', 3)
                ->has('recentAuditLogs'));
    }

    public function test_editor_can_view_audio_index(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get('/admin/audios')
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->component('Admin/Audios/Index')
                ->has('audios')
                ->has('teachers')
                ->has('statuses'));
    }

    public function test_dashboard_redirect_requires_authentication(): void
    {
        $this->get('/dashboard')->assertRedirect('/login');
    }
}
