<script setup>
import AdminLayout from '@/Layouts/AdminLayout.vue';
import Pagination from '@/Components/Pagination.vue';
import StatusBadge from '@/Components/StatusBadge.vue';
import { Head, Link, router } from '@inertiajs/vue3';
import { reactive } from 'vue';

const props = defineProps({
    audios: Object,
    filters: Object,
    teachers: Array,
    statuses: Array,
});

const state = reactive({
    search: props.filters?.search ?? '',
    status: props.filters?.status ?? '',
    teacher: props.filters?.teacher ?? '',
});

const applyFilters = () => {
    router.get(
        route('admin.audios.index'),
        {
            search: state.search || undefined,
            status: state.status || undefined,
            teacher: state.teacher || undefined,
        },
        { preserveState: true, replace: true },
    );
};

const resetFilters = () => {
    state.search = '';
    state.status = '';
    state.teacher = '';
    applyFilters();
};

const publish = (audio) => {
    router.post(route('admin.audios.publish', audio.slug), {}, { preserveScroll: true });
};

const archive = (audio) => {
    if (confirm(`Archive "${audio.title}"? It will disappear from the public catalog.`)) {
        router.post(route('admin.audios.archive', audio.slug), {}, { preserveScroll: true });
    }
};

const destroy = (audio) => {
    if (confirm(`Delete "${audio.title}"? This soft-deletes the record.`)) {
        router.delete(route('admin.audios.destroy', audio.slug), { preserveScroll: true });
    }
};

const formatDuration = (seconds) => {
    const total = Number(seconds ?? 0);
    const minutes = Math.floor(total / 60);
    const remainder = total % 60;

    return `${minutes}:${String(remainder).padStart(2, '0')}`;
};

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
        <Head title="Audios" />

        <template #header>
            <div>
                <h1 class="text-lg font-semibold text-[#28231F]">Audios</h1>
                <p class="text-sm text-[#7A6A5B]">Draft, publish and archive Dhamma recordings.</p>
            </div>
            <Link
                :href="route('admin.audios.create')"
                class="rounded-lg bg-[#B96A2C] px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-[#A25A24]"
            >
                New audio
            </Link>
        </template>

        <div class="rounded-2xl border border-[#EADBC8] bg-white shadow-sm">
            <form class="grid gap-3 border-b border-[#F0E5D7] p-4 sm:grid-cols-2 lg:grid-cols-4" @submit.prevent="applyFilters">
                <input
                    v-model="state.search"
                    type="search"
                    placeholder="Search title or teacher"
                    class="rounded-lg border-[#DCC9B2] bg-white px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                />
                <select
                    v-model="state.status"
                    class="rounded-lg border-[#DCC9B2] bg-white px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                >
                    <option value="">All statuses</option>
                    <option v-for="status in statuses" :key="status.value" :value="status.value">
                        {{ status.label }}
                    </option>
                </select>
                <select
                    v-model="state.teacher"
                    class="rounded-lg border-[#DCC9B2] bg-white px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                >
                    <option value="">All teachers</option>
                    <option v-for="teacher in teachers" :key="teacher.id" :value="teacher.slug">
                        {{ teacher.name }}
                    </option>
                </select>
                <div class="flex gap-2">
                    <button
                        type="submit"
                        class="flex-1 rounded-lg bg-[#B96A2C] px-3 py-2 text-sm font-semibold text-white transition hover:bg-[#A25A24]"
                    >
                        Filter
                    </button>
                    <button
                        type="button"
                        class="rounded-lg border border-[#DCC9B2] px-3 py-2 text-sm font-medium text-[#6B5A4C] transition hover:border-[#B96A2C]"
                        @click="resetFilters"
                    >
                        Reset
                    </button>
                </div>
            </form>

            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-[#F0E5D7] text-sm">
                    <thead class="bg-[#FBF4EA] text-left text-xs uppercase tracking-wide text-[#8A7969]">
                        <tr>
                            <th class="px-4 py-3 font-semibold">Audio</th>
                            <th class="px-4 py-3 font-semibold">Teacher</th>
                            <th class="px-4 py-3 font-semibold">Type</th>
                            <th class="px-4 py-3 font-semibold">Status</th>
                            <th class="px-4 py-3 font-semibold">Duration</th>
                            <th class="px-4 py-3 font-semibold">Published</th>
                            <th class="px-4 py-3 text-right font-semibold">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-[#F4EBDD]">
                        <tr v-for="audio in audios.data" :key="audio.id" class="hover:bg-[#FFFBF5]">
                            <td class="px-4 py-3">
                                <div class="flex items-center gap-3">
                                    <div class="h-10 w-10 shrink-0 overflow-hidden rounded-lg bg-[#F3E7D7]">
                                        <img
                                            v-if="audio.cover_image_url"
                                            :src="audio.cover_image_url"
                                            :alt="audio.title"
                                            class="h-full w-full object-cover"
                                        />
                                    </div>
                                    <div class="min-w-0">
                                        <Link
                                            :href="route('admin.audios.edit', audio.slug)"
                                            class="block max-w-xs truncate font-medium hover:text-[#B96A2C]"
                                        >
                                            {{ audio.title }}
                                        </Link>
                                        <div class="text-xs text-[#A39283]">{{ audio.slug }}</div>
                                    </div>
                                </div>
                            </td>
                            <td class="px-4 py-3 text-[#5C4633]">{{ audio.teacher?.name }}</td>
                            <td class="px-4 py-3 text-[#5C4633]">{{ audio.audio_type?.name }}</td>
                            <td class="px-4 py-3"><StatusBadge :status="audio.status" /></td>
                            <td class="px-4 py-3 text-[#5C4633]">{{ formatDuration(audio.duration_seconds) }}</td>
                            <td class="px-4 py-3 text-[#5C4633]">{{ formatDate(audio.published_at) }}</td>
                            <td class="px-4 py-3">
                                <div class="flex justify-end gap-2">
                                    <Link
                                        :href="route('admin.audios.edit', audio.slug)"
                                        class="rounded-md border border-[#DCC9B2] px-2.5 py-1 text-xs font-medium text-[#6B5A4C] transition hover:border-[#B96A2C] hover:text-[#B96A2C]"
                                    >
                                        Edit
                                    </Link>
                                    <button
                                        v-if="audio.status !== 'published'"
                                        type="button"
                                        class="rounded-md border border-emerald-200 bg-emerald-50 px-2.5 py-1 text-xs font-medium text-emerald-700 transition hover:bg-emerald-100"
                                        @click="publish(audio)"
                                    >
                                        Publish
                                    </button>
                                    <button
                                        v-if="audio.status === 'published'"
                                        type="button"
                                        class="rounded-md border border-amber-200 bg-amber-50 px-2.5 py-1 text-xs font-medium text-amber-700 transition hover:bg-amber-100"
                                        @click="archive(audio)"
                                    >
                                        Archive
                                    </button>
                                    <button
                                        type="button"
                                        class="rounded-md border border-rose-200 bg-rose-50 px-2.5 py-1 text-xs font-medium text-rose-700 transition hover:bg-rose-100"
                                        @click="destroy(audio)"
                                    >
                                        Delete
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <tr v-if="!audios.data.length">
                            <td colspan="7" class="px-4 py-12 text-center text-sm text-[#8A7969]">
                                No audios match the current filters.
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="border-t border-[#F0E5D7] px-4 py-3">
                <Pagination :paginator="audios" />
            </div>
        </div>
    </AdminLayout>
</template>
