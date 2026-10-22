<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        User::query()->updateOrCreate(
            ['email' => 'admin@example.com'],
            [
                'name' => 'Catalog Admin',
                'password' => 'password',
                'role' => 'admin',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
        );
    }
}
