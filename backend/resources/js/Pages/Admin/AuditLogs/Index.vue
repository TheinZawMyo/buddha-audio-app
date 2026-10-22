<script setup>
import AdminLayout from '@/Layouts/AdminLayout.vue';
import Pagination from '@/Components/Pagination.vue';
import { Head } from '@inertiajs/vue3';

defineProps({
    logs: Object,
});

const formatDate = (value) => {
    if (!value) {
        return '—';
    }

    return new Date(value).toLocaleString(undefined, {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
    });
};

const actionClasses = {
    created: 'bg-emerald-100 text-emerald-800',
    updated: 'bg-sky-100 text-sky-800',
    published: 'bg-[#B96A2C]/15 text-[#8B4D1D]',
    archived: 'bg-amber-100 text-amber-800',
    deleted: 'bg-rose-100 text-rose-700',
};
</script>

<template>
    <AdminLayout>
        <Head title="Audit logs" />

        <template #header>
            <div>
                <h1 class="text-lg font-semibold text-[#28231F]">Audit logs</h1>
                <p class="text-sm text-[#7A6A5B]">Every admin mutation is recorded for accountability.</p>
            </div>
        </template>

        <div class="rounded-2xl border border-[#EADBC8] bg-white shadow-sm">
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-[#F0E5D7] text-sm">
                    <thead class="bg-[#FBF4EA] text-left text-xs uppercase tracking-wide text-[#8A7969]">
                        <tr>
                            <th class="px-4 py-3 font-semibold">When</th>
                            <th class="px-4 py-3 font-semibold">User</th>
                            <th class="px-4 py-3 font-semibold">Action</th>
                            <th class="px-4 py-3 font-semibold">Description</th>
                            <th class="px-4 py-3 font-semibold">IP</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-[#F4EBDD]">
                        <tr v-for="log in logs.data" :key="log.id" class="hover:bg-[#FFFBF5]">
                            <td class="whitespace-nowrap px-4 py-3 text-[#5C4633]">{{ formatDate(log.created_at) }}</td>
                            <td class="px-4 py-3 text-[#5C4633]">{{ log.user?.name ?? 'System' }}</td>
                            <td class="px-4 py-3">
                                <span
                                    class="inline-flex rounded-full px-2.5 py-0.5 text-xs font-semibold capitalize"
                                    :class="actionClasses[log.action] ?? 'bg-slate-100 text-slate-700'"
                                >
                                    {{ log.action }}
                                </span>
                            </td>
                            <td class="px-4 py-3 text-[#4A3A2C]">{{ log.description }}</td>
                            <td class="px-4 py-3 text-[#8A7969]">{{ log.ip_address }}</td>
                        </tr>
                        <tr v-if="!logs.data.length">
                            <td colspan="5" class="px-4 py-12 text-center text-sm text-[#8A7969]">
                                No audit activity yet.
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="border-t border-[#F0E5D7] px-4 py-3">
                <Pagination :paginator="logs" />
            </div>
        </div>
    </AdminLayout>
</template>
