<?php

namespace App\Repositories\Contracts;

use App\Models\AuditLog;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

interface AuditLogRepositoryInterface
{
    public function paginate(int $perPage = 25): LengthAwarePaginator;

    /**
     * @param  array<string, mixed>  $attributes
     */
    public function create(array $attributes): AuditLog;

    /**
     * @return Collection<int, AuditLog>
     */
    public function recent(int $limit): Collection;
}
