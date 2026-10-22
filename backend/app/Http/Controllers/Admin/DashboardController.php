<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\AuditLogService;
use App\Services\DashboardService;
use Inertia\Inertia;
use Inertia\Response;

class DashboardController extends Controller
{
    public function index(DashboardService $dashboard, AuditLogService $auditLogs): Response
    {
        return Inertia::render('Admin/Dashboard', [
            ...$dashboard->summary(),
            'recentAuditLogs' => $auditLogs->recent(5),
        ]);
    }
}
