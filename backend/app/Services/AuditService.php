<?php

namespace App\Services;

use App\Models\AuditLog;
use App\Repositories\Contracts\AuditLogRepositoryInterface;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Auth;

class AuditService
{
    public function __construct(private readonly AuditLogRepositoryInterface $auditLogs) {}

    /**
     * @param  array<string, mixed>  $changes
     */
    public function record(string $action, Model $subject, ?string $description = null, array $changes = []): AuditLog
    {
        return $this->auditLogs->create([
            'user_id' => Auth::id(),
            'action' => $action,
            'auditable_type' => $subject::class,
            'auditable_id' => (string) $subject->getKey(),
            'description' => $description,
            'changes' => $this->filterChanges($changes),
            'ip_address' => request()->ip(),
        ]);
    }

    /**
     * @param  array<string, mixed>  $changes
     * @return array<string, mixed>
     */
    private function filterChanges(array $changes): array
    {
        unset(
            $changes['password'],
            $changes['password_confirmation'],
            $changes['audio_file'],
            $changes['cover_image'],
        );

        return $changes;
    }
}
