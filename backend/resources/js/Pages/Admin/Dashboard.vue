<script setup>
import AdminLayout from '@/Layouts/AdminLayout.vue';
import StatusBadge from '@/Components/StatusBadge.vue';
import { Head, Link } from '@inertiajs/vue3';

defineProps({
    statusCounts: Object,
    teacherCount: Number,
    categoryCount: Number,
    typeCount: Number,
    recentAudios: Array,
    recentAuditLogs: Array,
});

const statusCards = [
    { key: 'published', label: 'Published', accent: 'bg-emerald-500' },
    { key: 'draft', label: 'Drafts', accent: 'bg-slate-400' },
    { key: 'processing', label: 'Processing', accent: 'bg-amber-500' },
    { key: 'archived', label: 'Archived', accent: 'bg-rose-500' },
];

const formatDate = (value) => {
    if (!value) {
        return '—';
    }

    return new Date(value).toLocaleDateString(undefined, {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
    });
};
</script>

<template>
    <AdminLayout>
        <Head title="Dashboard" />

        <template #header>
            <div>
                <h1 class="text-lg font-semibold text-[#28231F]">Dashboard</h1>
                <p class="text-sm text-[#7A6A5B]">A snapshot of the published Dhamma catalog.</p>
            </div>
            <Link
                :href="route('admin.audios.create')"
                class="rounded-lg bg-[#B96A2C] px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-[#A25A24]"
            >
                New audio
            </Link>
        </template>

        <section class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <div
                v-for="card in statusCards"
                :key="card.key"
                class="rounded-2xl border border-[#EADBC8] bg-white p-5 shadow-sm"
            >
                <div class="flex items-center justify-between">
                    <div class="text-sm text-[#7A6A5B]">{{ card.label }}</div>
                    <div class="h-2 w-2 rounded-full" :class="card.accent" />
                </div>
                <div class="mt-2 text-3xl font-semibold tracking-tight">
                    {{ statusCounts?.[card.key] ?? 0 }}
                </div>
            </div>
        </section>

        <section class="mt-4 grid gap-4 sm:grid-cols-3">
            <Link
                :href="route('admin.teachers.index')"
                class="rounded-2xl border border-[#EADBC8] bg-white p-5 shadow-sm transition hover:border-[#B96A2C]"
            >
                <div class="text-sm text-[#7A6A5B]">Teachers</div>
                <div class="mt-1 text-2xl font-semibold">{{ teacherCount }}</div>
            </Link>
            <Link
                :href="route('admin.categories.index')"
                class="rounded-2xl border border-[#EADBC8] bg-white p-5 shadow-sm transition hover:border-[#B96A2C]"
            >
                <div class="text-sm text-[#7A6A5B]">Categories</div>
                <div class="mt-1 text-2xl font-semibold">{{ categoryCount }}</div>
            </Link>
            <Link
                :href="route('admin.audio-types.index')"
                class="rounded-2xl border border-[#EADBC8] bg-white p-5 shadow-sm transition hover:border-[#B96A2C]"
            >
                <div class="text-sm text-[#7A6A5B]">Audio types</div>
                <div class="mt-1 text-2xl font-semibold">{{ typeCount }}</div>
            </Link>
        </section>

        <div class="mt-6 grid gap-6 xl:grid-cols-3">
            <section class="rounded-2xl border border-[#EADBC8] bg-white shadow-sm xl:col-span-2">
                <div class="flex items-center justify-between border-b border-[#F0E5D7] px-5 py-4">
                    <h2 class="text-sm font-semibold">Recently added audios</h2>
                    <Link :href="route('admin.audios.index')" class="text-xs font-semibold text-[#B96A2C]">
                        View all
                    </Link>
                </div>
                <div class="divide-y divide-[#F4EBDD]">
                    <div
                        v-for="audio in recentAudios"
                        :key="audio.id"
                        class="flex items-center gap-3 px-5 py-3.5"
                    >
                        <div class="h-11 w-11 shrink-0 overflow-hidden rounded-lg bg-[#F3E7D7]">
                            <img
                                v-if="audio.cover_image_url"
                                :src="audio.cover_image_url"
                                :alt="audio.title"
                                class="h-full w-full object-cover"
                            />
                        </div>
                        <div class="min-w-0 flex-1">
                            <Link
                                :href="route('admin.audios.edit', audio.slug)"
                                class="block truncate text-sm font-medium hover:text-[#B96A2C]"
                            >
                                {{ audio.title }}
                            </Link>
                            <div class="truncate text-xs text-[#8A7969]">
                                {{ audio.teacher?.name }} · {{ audio.audio_type?.name }}
                            </div>
                        </div>
                        <StatusBadge :status="audio.status" />
                    </div>
                    <div v-if="!recentAudios?.length" class="px-5 py-10 text-center text-sm text-[#8A7969]">
                        No audios yet. Add the first one.
                    </div>
                </div>
            </section>

            <section class="rounded-2xl border border-[#EADBC8] bg-white shadow-sm">
                <div class="flex items-center justify-between border-b border-[#F0E5D7] px-5 py-4">
                    <h2 class="text-sm font-semibold">Latest activity</h2>
                    <Link :href="route('admin.audit-logs.index')" class="text-xs font-semibold text-[#B96A2C]">
                        Audit log
                    </Link>
                </div>
                <ul class="divide-y divide-[#F4EBDD]">
                    <li v-for="log in recentAuditLogs" :key="log.id" class="px-5 py-3.5">
                        <div class="flex items-center justify-between gap-2">
                            <span class="text-xs font-semibold uppercase tracking-wide text-[#B96A2C]">
                                {{ log.action }}
                            </span>
                            <span class="text-[11px] text-[#A39283]">{{ formatDate(log.created_at) }}</span>
                        </div>
                        <p class="mt-1 text-sm text-[#4A3A2C]">{{ log.description }}</p>
                        <p class="text-xs text-[#8A7969]">{{ log.user?.name ?? 'System' }}</p>
                    </li>
                    <li v-if="!recentAuditLogs?.length" class="px-5 py-10 text-center text-sm text-[#8A7969]">
                        No activity recorded yet.
                    </li>
                </ul>
            </section>
        </div>
    </AdminLayout>
</template>
