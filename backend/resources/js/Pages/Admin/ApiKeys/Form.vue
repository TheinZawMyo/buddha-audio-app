<script setup>
import AdminLayout from '@/Layouts/AdminLayout.vue';
import InputError from '@/Components/InputError.vue';
import { Head, Link, useForm } from '@inertiajs/vue3';
import { computed } from 'vue';

const props = defineProps({ apiKey: Object });

const editing = computed(() => Boolean(props.apiKey));

const form = useForm({
    name: props.apiKey?.name ?? '',
    is_active: props.apiKey?.is_active ?? true,
    rate_limit_per_minute: props.apiKey?.rate_limit_per_minute ?? 300,
    expires_at: props.apiKey?.expires_at ?? '',
});

const submit = () => {
    if (editing.value) {
        form.put(route('admin.api-keys.update', props.apiKey.id), { preserveScroll: true });
        return;
    }

    form.post(route('admin.api-keys.store'));
};
</script>

<template>
    <AdminLayout>
        <Head :title="editing ? 'Edit API key' : 'New API key'" />

        <template #header>
            <div>
                <h1 class="text-lg font-semibold text-[#28231F]">{{ editing ? 'Edit API key' : 'New API key' }}</h1>
                <p class="text-sm text-[#7A6A5B]">Set a name, request limit, and optional expiry.</p>
            </div>
            <Link
                :href="route('admin.api-keys.index')"
                class="rounded-lg border border-[#DCC9B2] px-3 py-2 text-sm font-medium text-[#6B5A4C] transition hover:border-[#B96A2C]"
            >
                Back
            </Link>
        </template>

        <form class="max-w-2xl space-y-4 rounded-2xl border border-[#EADBC8] bg-white p-5 shadow-sm" @submit.prevent="submit">
            <div>
                <label for="api-key-name" class="mb-1 block text-sm font-medium text-[#4A3A2C]">Key name</label>
                <input
                    id="api-key-name"
                    v-model="form.name"
                    type="text"
                    maxlength="100"
                    autocomplete="off"
                    class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                />
                <InputError class="mt-1.5" :message="form.errors.name" />
            </div>

            <div>
                <label for="api-key-limit" class="mb-1 block text-sm font-medium text-[#4A3A2C]">Requests per minute</label>
                <input
                    id="api-key-limit"
                    v-model.number="form.rate_limit_per_minute"
                    type="number"
                    min="1"
                    max="10000"
                    step="1"
                    class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                />
                <InputError class="mt-1.5" :message="form.errors.rate_limit_per_minute" />
            </div>

            <div>
                <label for="api-key-expiry" class="mb-1 block text-sm font-medium text-[#4A3A2C]">Expires at (optional)</label>
                <input
                    id="api-key-expiry"
                    v-model="form.expires_at"
                    type="datetime-local"
                    class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                />
                <InputError class="mt-1.5" :message="form.errors.expires_at" />
            </div>

            <label v-if="editing" class="flex items-center gap-2 text-sm text-[#4A3A2C]">
                <input
                    v-model="form.is_active"
                    type="checkbox"
                    class="rounded border-[#DCC9B2] text-[#B96A2C] focus:ring-[#B96A2C]"
                />
                Active
            </label>

            <div v-if="editing" class="rounded-lg bg-[#FBF4EA] p-3 text-sm text-[#6B5A4C]">
                Key prefix: <code>{{ apiKey.key_prefix }}…</code>. The secret itself is never stored or shown again. Create a replacement key to rotate it.
            </div>
            <div v-else class="rounded-lg bg-amber-50 p-3 text-sm leading-6 text-amber-900">
                The full key is shown once after creation. Store it in the Flutter .env.json file and rebuild the app. Anyone who can download the app may extract that key.
            </div>

            <button
                type="submit"
                :disabled="form.processing"
                class="rounded-lg bg-[#B96A2C] px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-[#A25A24] disabled:opacity-60"
            >
                {{ editing ? 'Save changes' : 'Create API key' }}
            </button>
        </form>
    </AdminLayout>
</template>
