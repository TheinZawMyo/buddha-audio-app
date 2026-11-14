<script setup>
import AdminLayout from '@/Layouts/AdminLayout.vue';
import Pagination from '@/Components/Pagination.vue';
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import { computed } from 'vue';

defineProps({ keys: Object });

const page = usePage();
const generatedKey = computed(() => page.props.flash?.apiKey ?? null);

const copyKey = async () => {
    if (generatedKey.value) {
        await navigator.clipboard.writeText(generatedKey.value);
    }
};

const status = (apiKey) => {
    if (apiKey.is_expired) {
        return 'Expired';
    }

    return apiKey.is_active ? 'Active' : 'Inactive';
};

const destroy = (apiKey) => {
    if (confirm(`Delete API key "${apiKey.name}"? Apps using it will lose API access.`)) {
        router.delete(route('admin.api-keys.destroy', apiKey.id), { preserveScroll: true });
    }
};
</script>

<template>
    <AdminLayout>
        <Head title="API keys" />

        <template #header>
            <div>
                <h1 class="text-lg font-semibold text-[#28231F]">API keys</h1>
                <p class="text-sm text-[#7A6A5B]">Create and revoke keys used by the mobile app.</p>
            </div>
            <Link
                :href="route('admin.api-keys.create')"
                class="rounded-lg bg-[#B96A2C] px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-[#A25A24]"
            >
                New API key
            </Link>
        </template>

        <div class="mb-5 rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm leading-6 text-amber-900">
            A key compiled into a Flutter app can be extracted and reused. Use these keys for app identification, rotation,
            and rate limiting; they do not prove who is using the app or protect private user data.
        </div>

        <div v-if="generatedKey" class="mb-5 rounded-2xl border border-emerald-200 bg-emerald-50 p-5 text-emerald-950">
            <h2 class="font-semibold">Copy this key now</h2>
            <p class="mt-1 text-sm">It is stored as a hash and cannot be shown again. Add it to app/.env.json and rebuild the app.</p>
            <div class="mt-3 flex flex-col gap-2 sm:flex-row">
                <code class="min-w-0 flex-1 break-all rounded-lg border border-emerald-200 bg-white px-3 py-2 text-sm">{{ generatedKey }}</code>
                <button
                    type="button"
                    class="rounded-lg bg-emerald-800 px-4 py-2 text-sm font-semibold text-white hover:bg-emerald-900"
                    @click="copyKey"
                >
                    Copy key
                </button>
            </div>
        </div>

        <div class="overflow-hidden rounded-2xl border border-[#EADBC8] bg-white shadow-sm">
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-[#F0E5D7] text-sm">
                    <thead class="bg-[#FBF4EA] text-left text-xs uppercase tracking-wide text-[#8A7969]">
                        <tr>
                            <th class="px-4 py-3 font-semibold">Name / key prefix</th>
                            <th class="px-4 py-3 font-semibold">Status</th>
                            <th class="px-4 py-3 font-semibold">Limit</th>
                            <th class="px-4 py-3 font-semibold">Last used</th>
                            <th class="px-4 py-3 font-semibold">Expires</th>
                            <th class="px-4 py-3 text-right font-semibold">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-[#F4EBDD]">
                        <tr v-for="apiKey in keys.data" :key="apiKey.id" class="hover:bg-[#FFFBF5]">
                            <td class="px-4 py-3">
                                <div class="font-medium">{{ apiKey.name }}</div>
                                <code class="text-xs text-[#7A6A5B]">{{ apiKey.key_prefix }}…</code>
                            </td>
                            <td class="px-4 py-3">
                                <span
                                    class="inline-flex rounded-full px-2.5 py-0.5 text-xs font-semibold ring-1 ring-inset"
                                    :class="apiKey.is_expired ? 'bg-amber-100 text-amber-800 ring-amber-200' : apiKey.is_active ? 'bg-emerald-100 text-emerald-800 ring-emerald-200' : 'bg-slate-100 text-slate-600 ring-slate-200'"
                                >
                                    {{ status(apiKey) }}
                                </span>
                            </td>
                            <td class="px-4 py-3 text-[#5C4633]">{{ apiKey.rate_limit_per_minute }} / minute</td>
                            <td class="px-4 py-3 text-[#5C4633]">{{ apiKey.last_used_at ?? 'Never' }}</td>
                            <td class="px-4 py-3 text-[#5C4633]">{{ apiKey.expires_at ?? 'Never' }}</td>
                            <td class="px-4 py-3">
                                <div class="flex justify-end gap-2">
                                    <Link
                                        :href="route('admin.api-keys.edit', apiKey.id)"
                                        class="rounded-md border border-[#DCC9B2] px-2.5 py-1 text-xs font-medium text-[#6B5A4C] transition hover:border-[#B96A2C] hover:text-[#B96A2C]"
                                    >
                                        Edit
                                    </Link>
                                    <button
                                        type="button"
                                        class="rounded-md border border-rose-200 bg-rose-50 px-2.5 py-1 text-xs font-medium text-rose-700 transition hover:bg-rose-100"
                                        @click="destroy(apiKey)"
                                    >
                                        Delete
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <tr v-if="!keys.data.length">
                            <td colspan="6" class="px-4 py-12 text-center text-sm text-[#8A7969]">No API keys created.</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="border-t border-[#F0E5D7] px-4 py-3">
                <Pagination :paginator="keys" />
            </div>
        </div>
    </AdminLayout>
</template>
