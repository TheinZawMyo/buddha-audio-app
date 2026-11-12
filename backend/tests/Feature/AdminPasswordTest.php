<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Inertia\Testing\AssertableInertia as Assert;
use Tests\TestCase;

class AdminPasswordTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_is_redirected_to_login(): void
    {
        $this->get('/admin/password')->assertRedirect('/login');
    }

    public function test_admin_can_view_change_password_page(): void
    {
        $user = User::factory()->admin()->create();

        $this->actingAs($user)
            ->get('/admin/password')
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page->component('Admin/Password/Edit'));
    }

    public function test_admin_can_change_their_password(): void
    {
        $user = User::factory()->admin()->create();

        $response = $this
            ->actingAs($user)
            ->from('/admin/password')
            ->put('/password', [
                'current_password' => 'password',
                'password' => 'new-secret-password',
                'password_confirmation' => 'new-secret-password',
            ]);

        $response
            ->assertSessionHasNoErrors()
            ->assertRedirect('/admin/password');

        $this->assertTrue(Hash::check('new-secret-password', $user->refresh()->password));
    }

    public function test_wrong_current_password_is_rejected(): void
    {
        $user = User::factory()->admin()->create();

        $response = $this
            ->actingAs($user)
            ->from('/admin/password')
            ->put('/password', [
                'current_password' => 'wrong-password',
                'password' => 'new-secret-password',
                'password_confirmation' => 'new-secret-password',
            ]);

        $response
            ->assertSessionHasErrors('current_password')
            ->assertRedirect('/admin/password');

        $this->assertTrue(Hash::check('password', $user->refresh()->password));
    }
}
