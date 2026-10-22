<script setup>
import AdminLayout from '@/Layouts/AdminLayout.vue';
import Pagination from '@/Components/Pagination.vue';
import { Head, Link, router } from '@inertiajs/vue3';
import { reactive } from 'vue';

const props = defineProps({
    teachers: Object,
    filters: Object,
});

const state = reactive({ search: props.filters?.search ?? '' });

const search = () => {
    router.get(
        route('admin.teachers.index'),
        { search: state.search || undefined },
        { preserveState: true, replace: true },
    );
};

const destroy = (teacher) => {
    if (confirm(`Delete "${teacher.name}"? Audios linked to this teacher must be reassigned first.`)) {
        router.delete(route('admin.teachers.destroy', teacher.slug), { preserveScroll: true });
    }
};
</script>

<template>
    <AdminLayout>
        <Head title="Teachers" />

        <template #header>
            <div>
                <h1 class="text-lg font-semibold text-[#28231F]">Teachers</h1>
                <p class="text-sm text-[#7A6A5B]">Manage the Dhamma teachers shown in the app.</p>
            </div>
            <Link
                :href="route('admin.teachers.create')"
                class="rounded-lg bg-[#B96A2C] px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-[#A25A24]"
            >
                New teacher
            </Link>
        </template>

        <div class="rounded-2xl border border-[#EADBC8] bg-white shadow-sm">
            <form class="flex flex-col gap-3 border-b border-[#F0E5D7] p-4 sm:flex-row" @submit.prevent="search">
                <input
                    v-model="state.search"
                    type="search"
                    placeholder="Search by name or slug"
                    class="w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C] sm:max-w-xs"
                />
                <button
                    type="submit"
                    class="rounded-lg bg-[#B96A2C] px-4 py-2 text-sm font-semibold text-white transition hover:bg-[#A25A24]"
                >
                    Search
                </button>
            </form>

            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-[#F0E5D7] text-sm">
                    <thead class="bg-[#FBF4EA] text-left text-xs uppercase tracking-wide text-[#8A7969]">
                        <tr>
                            <th class="px-4 py-3 font-semibold">Teacher</th>
                            <th class="px-4 py-3 font-semibold">Slug</th>
                            <th class="px-4 py-3 font-semibold">Audios</th>
                            <th class="px-4 py-3 font-semibold">Status</th>
                            <th class="px-4 py-3 text-right font-semibold">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-[#F4EBDD]">
                        <tr v-for="teacher in teachers.data" :key="teacher.id" class="hover:bg-[#FFFBF5]">
                            <td class="px-4 py-3">
                                <div class="flex items-center gap-3">
                                    <div class="h-10 w-10 shrink-0 overflow-hidden rounded-full bg-[#F3E7D7]">
                                        <img
                                            v-if="teacher.photo_url"
                                            :src="teacher.photo_url"
                                            :alt="teacher.name"
                                            class="h-full w-full object-cover"
                                        />
                                        <div v-else class="grid h-full w-full place-items-center text-sm font-semibold text-[#B96A2C]">
                                            {{ teacher.name?.charAt(0) }}
                                        </div>
                                    </div>
                                    <div class="min-w-0">
                                        <div class="truncate font-medium">{{ teacher.name }}</div>
                                        <div class="truncate text-xs text-[#A39283]">{{ teacher.short_name }}</div>
                                    </div>
                                </div>
                            </td>
                            <td class="px-4 py-3 text-[#5C4633]">{{ teacher.slug }}</td>
                            <td class="px-4 py-3 text-[#5C4633]">{{ teacher.audios_count }}</td>
                            <td class="px-4 py-3">
                                <span
                                    class="inline-flex rounded-full px-2.5 py-0.5 text-xs font-semibold ring-1 ring-inset"
                                    :class="
                                        teacher.is_active
                                            ? 'bg-emerald-100 text-emerald-800 ring-emerald-200'
                                            : 'bg-slate-100 text-slate-600 ring-slate-200'
                                    "
                                >
                                    {{ teacher.is_active ? 'Active' : 'Inactive' }}
                                </span>
                            </td>
                            <td class="px-4 py-3">
                                <div class="flex justify-end gap-2">
                                    <Link
                                        :href="route('admin.teachers.edit', teacher.slug)"
                                        class="rounded-md border border-[#DCC9B2] px-2.5 py-1 text-xs font-medium text-[#6B5A4C] transition hover:border-[#B96A2C] hover:text-[#B96A2C]"
                                    >
                                        Edit
                                    </Link>
                                    <button
                                        type="button"
                                        class="rounded-md border border-rose-200 bg-rose-50 px-2.5 py-1 text-xs font-medium text-rose-700 transition hover:bg-rose-100"
                                        @click="destroy(teacher)"
                                    >
                                        Delete
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <tr v-if="!teachers.data.length">
                            <td colspan="5" class="px-4 py-12 text-center text-sm text-[#8A7969]">
                                No teachers found.
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="border-t border-[#F0E5D7] px-4 py-3">
                <Pagination :paginator="teachers" />
            </div>
        </div>
    </AdminLayout>
</template>
