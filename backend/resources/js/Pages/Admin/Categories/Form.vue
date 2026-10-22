<script setup>
import AdminLayout from '@/Layouts/AdminLayout.vue';
import InputError from '@/Components/InputError.vue';
import { Head, Link, router, useForm } from '@inertiajs/vue3';
import { computed } from 'vue';

const props = defineProps({
    category: Object,
});

const editing = computed(() => Boolean(props.category));

const form = useForm({
    name: props.category?.name ?? '',
    slug: props.category?.slug ?? '',
    description: props.category?.description ?? '',
    sort_order: props.category?.sort_order ?? 0,
    is_active: props.category?.is_active ?? true,
});

const submit = () => {
    if (editing.value) {
        form.put(route('admin.categories.update', props.category.slug), { preserveScroll: true });
        return;
    }

    form.post(route('admin.categories.store'));
};

const destroy = () => {
    if (confirm(`Delete "${props.category.name}"?`)) {
        router.delete(route('admin.categories.destroy', props.category.slug));
    }
};
</script>

<template>
    <AdminLayout>
        <Head :title="editing ? 'Edit category' : 'New category'" />

        <template #header>
            <div>
                <h1 class="text-lg font-semibold text-[#28231F]">{{ editing ? 'Edit category' : 'New category' }}</h1>
                <p class="text-sm text-[#7A6A5B]">Categories can be assigned to many audios.</p>
            </div>
            <div class="flex items-center gap-2">
                <Link
                    :href="route('admin.categories.index')"
                    class="rounded-lg border border-[#DCC9B2] px-3 py-2 text-sm font-medium text-[#6B5A4C] transition hover:border-[#B96A2C]"
                >
                    Back
                </Link>
                <button
                    type="button"
                    :disabled="form.processing"
                    class="rounded-lg bg-[#B96A2C] px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-[#A25A24] disabled:opacity-60"
                    @click="submit"
                >
                    {{ editing ? 'Save changes' : 'Create category' }}
                </button>
            </div>
        </template>

        <form class="max-w-2xl space-y-4 rounded-2xl border border-[#EADBC8] bg-white p-5 shadow-sm" @submit.prevent="submit">
            <div>
                <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">Name</label>
                <input
                    v-model="form.name"
                    type="text"
                    class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                />
                <InputError class="mt-1.5" :message="form.errors.name" />
            </div>

            <div>
                <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">Slug</label>
                <input
                    v-model="form.slug"
                    type="text"
                    placeholder="auto-generated when empty"
                    class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                />
                <InputError class="mt-1.5" :message="form.errors.slug" />
            </div>

            <div>
                <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">Description</label>
                <textarea
                    v-model="form.description"
                    rows="4"
                    class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                />
                <InputError class="mt-1.5" :message="form.errors.description" />
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">Sort order</label>
                    <input
                        v-model.number="form.sort_order"
                        type="number"
                        min="0"
                        class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                    />
                    <InputError class="mt-1.5" :message="form.errors.sort_order" />
                </div>
                <label class="flex items-center gap-2 self-end pb-2 text-sm text-[#4A3A2C]">
                    <input
                        v-model="form.is_active"
                        type="checkbox"
                        class="rounded border-[#DCC9B2] text-[#B96A2C] focus:ring-[#B96A2C]"
                    />
                    Active in public catalog
                </label>
            </div>

            <button
                v-if="editing"
                type="button"
                class="rounded-lg border border-rose-200 bg-rose-50 px-4 py-2 text-sm font-semibold text-rose-700 transition hover:bg-rose-100"
                @click="destroy"
            >
                Delete category
            </button>
        </form>
    </AdminLayout>
</template>
