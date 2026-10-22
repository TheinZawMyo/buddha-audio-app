<?php

namespace App\Repositories\Eloquent;

use App\Models\AuditLog;
use App\Repositories\Contracts\AuditLogRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class EloquentAuditLogRepository implements AuditLogRepositoryInterface
{
    public function paginate(int $perPage = 25): LengthAwarePaginator
    {
        return AuditLog::query()
            ->with('user')
            ->latest('created_at')
            ->latest('id')
            ->paginate($perPage);
    }

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function create(array $attributes): AuditLog
    {
        return AuditLog::query()->create($attributes);
    }

    /**
     * @return Collection<int, AuditLog>
     */
    public function recent(int $limit): Collection
    {
        return AuditLog::query()
            ->with('user')
            ->latest('created_at')
            ->latest('id')
            ->limit($limit)
            ->get();
    }
}
