<script setup>
import AdminLayout from '@/Layouts/AdminLayout.vue';
import InputError from '@/Components/InputError.vue';
import { Head, Link, router, useForm } from '@inertiajs/vue3';
import { computed, ref } from 'vue';

const props = defineProps({
    teacher: Object,
});

const editing = computed(() => Boolean(props.teacher));
const preview = ref(null);

const form = useForm({
    name: props.teacher?.name ?? '',
    short_name: props.teacher?.short_name ?? '',
    slug: props.teacher?.slug ?? '',
    bio: props.teacher?.bio ?? '',
    photo: null,
    sort_order: props.teacher?.sort_order ?? 0,
    is_active: props.teacher?.is_active ?? true,
});

const currentPhoto = computed(() => preview.value ?? props.teacher?.photo_url ?? null);

const choosePhoto = (event) => {
    const file = event.target.files[0] ?? null;
    form.photo = file;

    if (file) {
        preview.value = URL.createObjectURL(file);
    }
};

const submit = () => {
    if (editing.value) {
        form.put(route('admin.teachers.update', props.teacher.slug), { forceFormData: true, preserveScroll: true });
        return;
    }

    form.post(route('admin.teachers.store'), { forceFormData: true });
};

const destroy = () => {
    if (confirm(`Delete "${props.teacher.name}"?`)) {
        router.delete(route('admin.teachers.destroy', props.teacher.slug));
    }
};
</script>

<template>
    <AdminLayout>
        <Head :title="editing ? 'Edit teacher' : 'New teacher'" />

        <template #header>
            <div>
                <h1 class="text-lg font-semibold text-[#28231F]">{{ editing ? 'Edit teacher' : 'New teacher' }}</h1>
                <p class="text-sm text-[#7A6A5B]">Teachers group audios in the listener app.</p>
            </div>
            <div class="flex items-center gap-2">
                <Link
                    :href="route('admin.teachers.index')"
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
                    {{ editing ? 'Save changes' : 'Create teacher' }}
                </button>
            </div>
        </template>

        <form class="grid gap-6 xl:grid-cols-3" @submit.prevent="submit">
            <section class="space-y-4 rounded-2xl border border-[#EADBC8] bg-white p-5 shadow-sm xl:col-span-2">
                <div>
                    <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">Name</label>
                    <input
                        v-model="form.name"
                        type="text"
                        class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                    />
                    <InputError class="mt-1.5" :message="form.errors.name" />
                </div>

                <div class="grid gap-4 sm:grid-cols-2">
                    <div>
                        <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">Short name</label>
                        <input
                            v-model="form.short_name"
                            type="text"
                            class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                        />
                        <InputError class="mt-1.5" :message="form.errors.short_name" />
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
                </div>

                <div>
                    <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">Biography</label>
                    <textarea
                        v-model="form.bio"
                        rows="6"
                        class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                    />
                    <InputError class="mt-1.5" :message="form.errors.bio" />
                </div>
            </section>

            <div class="space-y-6">
                <section class="rounded-2xl border border-[#EADBC8] bg-white p-5 shadow-sm">
                    <h2 class="text-sm font-semibold">Photo</h2>
                    <div class="mt-4 overflow-hidden rounded-xl border border-[#EADBC8] bg-[#F3E7D7]">
                        <img v-if="currentPhoto" :src="currentPhoto" alt="Teacher photo" class="aspect-square w-full object-cover" />
                        <div v-else class="grid aspect-square place-items-center text-sm text-[#A39283]">No photo</div>
                    </div>
                    <input
                        type="file"
                        accept="image/jpeg,image/png,image/webp"
                        class="mt-3 block w-full text-sm text-[#6B5A4C] file:mr-3 file:rounded-md file:border-0 file:bg-[#70401F] file:px-3 file:py-2 file:text-xs file:font-semibold file:text-white"
                        @change="choosePhoto"
                    />
                    <InputError class="mt-2" :message="form.errors.photo" />
                </section>

                <section class="space-y-4 rounded-2xl border border-[#EADBC8] bg-white p-5 shadow-sm">
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

                    <label class="flex items-center gap-2 text-sm text-[#4A3A2C]">
                        <input
                            v-model="form.is_active"
                            type="checkbox"
                            class="rounded border-[#DCC9B2] text-[#B96A2C] focus:ring-[#B96A2C]"
                        />
                        Active in public catalog
                    </label>

                    <button
                        v-if="editing"
                        type="button"
                        class="w-full rounded-lg border border-rose-200 bg-rose-50 px-4 py-2 text-sm font-semibold text-rose-700 transition hover:bg-rose-100"
                        @click="destroy"
                    >
                        Delete teacher
                    </button>
                </section>
            </div>
        </form>
    </AdminLayout>
</template>
