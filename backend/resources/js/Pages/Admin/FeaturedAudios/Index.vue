<script setup>
import AdminLayout from '@/Layouts/AdminLayout.vue';
import Pagination from '@/Components/Pagination.vue';
import { Head, Link, router } from '@inertiajs/vue3';
import { reactive } from 'vue';

const props = defineProps({
    featuredAudios: Object,
    filters: Object,
});

const state = reactive({ search: props.filters?.search ?? '' });

const search = () => {
    router.get(
        route('admin.featured-audios.index'),
        { search: state.search || undefined },
        { preserveState: true, replace: true },
    );
};

const destroy = (featuredAudio) => {
    if (confirm(`Remove "${featuredAudio.audio?.title}" from the featured list?`)) {
        router.delete(route('admin.featured-audios.destroy', featuredAudio.id), { preserveScroll: true });
    }
};
</script>

<template>
    <AdminLayout>
        <Head title="Featured audios" />

        <template #header>
            <div>
                <h1 class="text-lg font-semibold text-[#28231F]">Featured audios</h1>
                <p class="text-sm text-[#7A6A5B]">Curate the Dhamma talks shown in the app home page featured row.</p>
            </div>
            <Link
                :href="route('admin.featured-audios.create')"
                class="rounded-lg bg-[#B96A2C] px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-[#A25A24]"
            >
                New featured audio
            </Link>
        </template>

        <div class="rounded-2xl border border-[#EADBC8] bg-white shadow-sm">
            <form class="flex flex-col gap-3 border-b border-[#F0E5D7] p-4 sm:flex-row" @submit.prevent="search">
                <input
                    v-model="state.search"
                    type="search"
                    placeholder="Search by title or teacher"
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
                            <th class="px-4 py-3 font-semibold">Order</th>
                            <th class="px-4 py-3 font-semibold">Audio</th>
                            <th class="px-4 py-3 font-semibold">Teacher</th>
                            <th class="px-4 py-3 font-semibold">Status</th>
                            <th class="px-4 py-3 text-right font-semibold">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-[#F4EBDD]">
                        <tr v-for="featuredAudio in featuredAudios.data" :key="featuredAudio.id" class="hover:bg-[#FFFBF5]">
                            <td class="px-4 py-3 text-[#5C4633]">{{ featuredAudio.sort_order }}</td>
                            <td class="px-4 py-3">
                                <div class="flex items-center gap-3">
                                    <div class="h-10 w-10 shrink-0 overflow-hidden rounded-lg bg-[#F3E7D7]">
                                        <img
                                            v-if="featuredAudio.audio?.cover_image_url"
                                            :src="featuredAudio.audio.cover_image_url"
                                            :alt="featuredAudio.audio.title"
                                            class="h-full w-full object-cover"
                                        />
                                        <div v-else class="grid h-full w-full place-items-center text-sm font-semibold text-[#B96A2C]">
                                            {{ featuredAudio.audio?.title?.charAt(0) }}
                                        </div>
                                    </div>
                                    <div class="min-w-0">
                                        <div class="truncate font-medium">{{ featuredAudio.audio?.title }}</div>
                                        <div class="truncate text-xs text-[#A39283]">{{ featuredAudio.audio?.slug }}</div>
                                    </div>
                                </div>
                            </td>
                            <td class="px-4 py-3 text-[#5C4633]">{{ featuredAudio.audio?.teacher?.name }}</td>
                            <td class="px-4 py-3">
                                <span
                                    class="inline-flex rounded-full px-2.5 py-0.5 text-xs font-semibold ring-1 ring-inset"
                                    :class="
                                        featuredAudio.is_active
                                            ? 'bg-emerald-100 text-emerald-800 ring-emerald-200'
                                            : 'bg-slate-100 text-slate-600 ring-slate-200'
                                    "
                                >
                                    {{ featuredAudio.is_active ? 'Active' : 'Hidden' }}
                                </span>
                            </td>
                            <td class="px-4 py-3">
                                <div class="flex justify-end gap-2">
                                    <Link
                                        :href="route('admin.featured-audios.edit', featuredAudio.id)"
                                        class="rounded-md border border-[#DCC9B2] px-2.5 py-1 text-xs font-medium text-[#6B5A4C] transition hover:border-[#B96A2C] hover:text-[#B96A2C]"
                                    >
                                        Edit
                                    </Link>
                                    <button
                                        type="button"
                                        class="rounded-md border border-rose-200 bg-rose-50 px-2.5 py-1 text-xs font-medium text-rose-700 transition hover:bg-rose-100"
                                        @click="destroy(featuredAudio)"
                                    >
                                        Remove
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <tr v-if="!featuredAudios.data.length">
                            <td colspan="5" class="px-4 py-12 text-center text-sm text-[#8A7969]">
                                No featured audios yet. The home page falls back to the latest published audios.
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="border-t border-[#F0E5D7] px-4 py-3">
                <Pagination :paginator="featuredAudios" />
            </div>
        </div>
    </AdminLayout>
</template>
