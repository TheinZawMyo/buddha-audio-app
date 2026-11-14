<?php

namespace App\Services;

use App\Models\ApiKey;

class ApiKeyService
{
    public function __construct(private readonly AuditService $audit) {}

    /**
     * @param  array{name: string, rate_limit_per_minute: int, expires_at: mixed}  $data
     * @return array{apiKey: ApiKey, plainTextKey: string}
     */
    public function create(array $data, int $creatorId): array
    {
        $plainTextKey = 'dw_live_'.bin2hex(random_bytes(32));
        $apiKey = ApiKey::query()->create([
            ...$data,
            'key_prefix' => substr($plainTextKey, 0, 24),
            'key_hash' => hash('sha256', $plainTextKey),
            'is_active' => true,
            'created_by' => $creatorId,
        ]);

        $this->audit->record('created', $apiKey, "API key \"{$apiKey->name}\" created.", $this->auditData($apiKey));

        return ['apiKey' => $apiKey, 'plainTextKey' => $plainTextKey];
    }

    /**
     * @param  array{name: string, is_active: bool, rate_limit_per_minute: int, expires_at: mixed}  $data
     */
    public function update(ApiKey $apiKey, array $data): ApiKey
    {
        $apiKey->update($data);

        $this->audit->record('updated', $apiKey, "API key \"{$apiKey->name}\" updated.", $this->auditData($apiKey));

        return $apiKey;
    }

    public function delete(ApiKey $apiKey): void
    {
        $this->audit->record('deleted', $apiKey, "API key \"{$apiKey->name}\" deleted.", $this->auditData($apiKey));
        $apiKey->delete();
    }

    /**
     * @return array{name: string, key_prefix: string, is_active: bool, rate_limit_per_minute: int, expires_at: ?string}
     */
    private function auditData(ApiKey $apiKey): array
    {
        return [
            'name' => $apiKey->name,
            'key_prefix' => $apiKey->key_prefix,
            'is_active' => $apiKey->is_active,
            'rate_limit_per_minute' => $apiKey->rate_limit_per_minute,
            'expires_at' => $apiKey->expires_at?->toIso8601String(),
        ];
    }
}
