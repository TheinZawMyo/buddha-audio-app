<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Inertia\Inertia;
use Inertia\Response;

class PasswordController extends Controller
{
    /**
     * Display the admin password form.
     */
    public function edit(): Response
    {
        return Inertia::render('Admin/Password/Edit');
    }
}
