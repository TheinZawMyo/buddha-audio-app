<?php

namespace App\Services;

use App\Models\AuditLog;
use App\Repositories\Contracts\AuditLogRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class AuditLogService
{
    public function __construct(private readonly AuditLogRepositoryInterface $auditLogs) {}

    public function paginate(): LengthAwarePaginator
    {
        return $this->auditLogs->paginate((int) config('catalog.per_page', 15));
    }

    /**
     * @return Collection<int, AuditLog>
     */
    public function recent(int $limit): Collection
    {
        return $this->auditLogs->recent($limit);
    }
}
