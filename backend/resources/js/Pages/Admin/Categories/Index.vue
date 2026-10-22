<script setup>
import AdminLayout from '@/Layouts/AdminLayout.vue';
import Pagination from '@/Components/Pagination.vue';
import { Head, Link, router } from '@inertiajs/vue3';
import { reactive } from 'vue';

const props = defineProps({
    categories: Object,
    filters: Object,
});

const state = reactive({ search: props.filters?.search ?? '' });

const search = () => {
    router.get(
        route('admin.categories.index'),
        { search: state.search || undefined },
        { preserveState: true, replace: true },
    );
};

const destroy = (category) => {
    if (confirm(`Delete "${category.name}"? It will be detached from audios.`)) {
        router.delete(route('admin.categories.destroy', category.slug), { preserveScroll: true });
    }
};
</script>

<template>
    <AdminLayout>
        <Head title="Categories" />

        <template #header>
            <div>
                <h1 class="text-lg font-semibold text-[#28231F]">Categories</h1>
                <p class="text-sm text-[#7A6A5B]">Filter groups such as Dhamma talks, paritta and patthana.</p>
            </div>
            <Link
                :href="route('admin.categories.create')"
                class="rounded-lg bg-[#B96A2C] px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-[#A25A24]"
            >
                New category
            </Link>
        </template>

        <div class="rounded-2xl border border-[#EADBC8] bg-white shadow-sm">
            <form class="flex flex-col gap-3 border-b border-[#F0E5D7] p-4 sm:flex-row" @submit.prevent="search">
                <input
                    v-model="state.search"
                    type="search"
                    placeholder="Search categories"
                    class="w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C] sm:max-w-xs"
                />
                <button type="submit" class="rounded-lg bg-[#B96A2C] px-4 py-2 text-sm font-semibold text-white">
                    Search
                </button>
            </form>

            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-[#F0E5D7] text-sm">
                    <thead class="bg-[#FBF4EA] text-left text-xs uppercase tracking-wide text-[#8A7969]">
                        <tr>
                            <th class="px-4 py-3 font-semibold">Name</th>
                            <th class="px-4 py-3 font-semibold">Slug</th>
                            <th class="px-4 py-3 font-semibold">Audios</th>
                            <th class="px-4 py-3 font-semibold">Order</th>
                            <th class="px-4 py-3 font-semibold">Status</th>
                            <th class="px-4 py-3 text-right font-semibold">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-[#F4EBDD]">
                        <tr v-for="category in categories.data" :key="category.id" class="hover:bg-[#FFFBF5]">
                            <td class="px-4 py-3 font-medium">{{ category.name }}</td>
                            <td class="px-4 py-3 text-[#5C4633]">{{ category.slug }}</td>
                            <td class="px-4 py-3 text-[#5C4633]">{{ category.audios_count }}</td>
                            <td class="px-4 py-3 text-[#5C4633]">{{ category.sort_order }}</td>
                            <td class="px-4 py-3">
                                <span
                                    class="inline-flex rounded-full px-2.5 py-0.5 text-xs font-semibold ring-1 ring-inset"
                                    :class="
                                        category.is_active
                                            ? 'bg-emerald-100 text-emerald-800 ring-emerald-200'
                                            : 'bg-slate-100 text-slate-600 ring-slate-200'
                                    "
                                >
                                    {{ category.is_active ? 'Active' : 'Inactive' }}
                                </span>
                            </td>
                            <td class="px-4 py-3">
                                <div class="flex justify-end gap-2">
                                    <Link
                                        :href="route('admin.categories.edit', category.slug)"
                                        class="rounded-md border border-[#DCC9B2] px-2.5 py-1 text-xs font-medium text-[#6B5A4C] transition hover:border-[#B96A2C] hover:text-[#B96A2C]"
                                    >
                                        Edit
                                    </Link>
                                    <button
                                        type="button"
                                        class="rounded-md border border-rose-200 bg-rose-50 px-2.5 py-1 text-xs font-medium text-rose-700 transition hover:bg-rose-100"
                                        @click="destroy(category)"
                                    >
                                        Delete
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <tr v-if="!categories.data.length">
                            <td colspan="6" class="px-4 py-12 text-center text-sm text-[#8A7969]">No categories found.</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="border-t border-[#F0E5D7] px-4 py-3">
                <Pagination :paginator="categories" />
            </div>
        </div>
    </AdminLayout>
</template>
