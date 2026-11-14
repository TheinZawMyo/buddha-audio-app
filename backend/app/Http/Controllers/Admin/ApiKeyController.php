<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreApiKeyRequest;
use App\Http\Requests\Admin\UpdateApiKeyRequest;
use App\Models\ApiKey;
use App\Services\ApiKeyService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Crypt;
use Inertia\Inertia;
use Inertia\Response;

class ApiKeyController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(): Response
    {
        $keys = ApiKey::query()
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->paginate(20)
            ->through(fn (ApiKey $apiKey): array => [
                'id' => $apiKey->id,
                'name' => $apiKey->name,
                'key_prefix' => $apiKey->key_prefix,
                'is_active' => $apiKey->is_active,
                'is_expired' => $apiKey->expires_at?->isPast() ?? false,
                'rate_limit_per_minute' => $apiKey->rate_limit_per_minute,
                'expires_at' => $apiKey->expires_at?->format('Y-m-d H:i'),
                'last_used_at' => $apiKey->last_used_at?->format('Y-m-d H:i'),
                'created_at' => $apiKey->created_at?->format('Y-m-d H:i'),
            ]);

        return Inertia::render('Admin/ApiKeys/Index', ['keys' => $keys]);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create(): Response
    {
        return Inertia::render('Admin/ApiKeys/Form', ['apiKey' => null]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreApiKeyRequest $request, ApiKeyService $apiKeys): RedirectResponse
    {
        $created = $apiKeys->create(
            $request->validated(),
            (int) $request->user()->getAuthIdentifier(),
        );

        return redirect()
            ->route('admin.api-keys.index')
            ->with('success', 'API key created. Copy the key now; it will not be shown again.')
            ->with('encryptedApiKey', Crypt::encryptString($created['plainTextKey']));
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(ApiKey $apiKey): Response
    {
        return Inertia::render('Admin/ApiKeys/Form', [
            'apiKey' => [
                'id' => $apiKey->id,
                'name' => $apiKey->name,
                'key_prefix' => $apiKey->key_prefix,
                'is_active' => $apiKey->is_active,
                'rate_limit_per_minute' => $apiKey->rate_limit_per_minute,
                'expires_at' => $apiKey->expires_at?->format('Y-m-d\\TH:i'),
            ],
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateApiKeyRequest $request, ApiKey $apiKey, ApiKeyService $apiKeys): RedirectResponse
    {
        $apiKeys->update($apiKey, $request->validated());

        return redirect()
            ->route('admin.api-keys.index')
            ->with('success', 'API key updated.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(ApiKey $apiKey, ApiKeyService $apiKeys): RedirectResponse
    {
        $apiKeys->delete($apiKey);

        return redirect()
            ->route('admin.api-keys.index')
            ->with('success', 'API key deleted.');
    }
}
