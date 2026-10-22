<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\AuditLogService;
use Inertia\Inertia;
use Inertia\Response;

class AuditLogController extends Controller
{
    public function index(AuditLogService $auditLogs): Response
    {
        return Inertia::render('Admin/AuditLogs/Index', [
            'logs' => $auditLogs->paginate(),
        ]);
    }
}
