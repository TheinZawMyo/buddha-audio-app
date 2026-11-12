<script setup>
import AdminLayout from '@/Layouts/AdminLayout.vue';
import InputError from '@/Components/InputError.vue';
import { Head, Link, router, useForm } from '@inertiajs/vue3';
import { computed } from 'vue';

const props = defineProps({
    featuredAudio: Object,
    audios: Array,
});

const editing = computed(() => Boolean(props.featuredAudio));

const form = useForm({
    audio_id: props.featuredAudio?.audio_id ?? props.audios[0]?.id ?? '',
    sort_order: props.featuredAudio?.sort_order ?? 0,
    is_active: props.featuredAudio?.is_active ?? true,
});

const submit = () => {
    if (editing.value) {
        form.put(route('admin.featured-audios.update', props.featuredAudio.id), { preserveScroll: true });
        return;
    }

    form.post(route('admin.featured-audios.store'));
};

const destroy = () => {
    if (confirm(`Remove "${props.featuredAudio.audio?.title}" from the featured list?`)) {
        router.delete(route('admin.featured-audios.destroy', props.featuredAudio.id));
    }
};
</script>

<template>
    <AdminLayout>
        <Head :title="editing ? 'Edit featured audio' : 'New featured audio'" />

        <template #header>
            <div>
                <h1 class="text-lg font-semibold text-[#28231F]">{{ editing ? 'Edit featured audio' : 'New featured audio' }}</h1>
                <p class="text-sm text-[#7A6A5B]">Choose a published audio and its position in the home page featured row.</p>
            </div>
            <div class="flex items-center gap-2">
                <Link
                    :href="route('admin.featured-audios.index')"
                    class="rounded-lg border border-[#DCC9B2] px-3 py-2 text-sm font-medium text-[#6B5A4C] transition hover:border-[#B96A2C]"
                >
                    Back
                </Link>
                <button
                    type="button"
                    :disabled="form.processing || (!editing && !audios.length)"
                    class="rounded-lg bg-[#B96A2C] px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-[#A25A24] disabled:opacity-60"
                    @click="submit"
                >
                    {{ editing ? 'Save changes' : 'Add to featured' }}
                </button>
            </div>
        </template>

        <form class="grid gap-6 xl:grid-cols-3" @submit.prevent="submit">
            <section class="space-y-4 rounded-2xl border border-[#EADBC8] bg-white p-5 shadow-sm xl:col-span-2">
                <div>
                    <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">Audio</label>
                    <select
                        v-model="form.audio_id"
                        class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                    >
                        <option value="" disabled>Select a published audio</option>
                        <option v-for="audio in audios" :key="audio.id" :value="audio.id">
                            {{ audio.title }} — {{ audio.teacher_name }}
                        </option>
                    </select>
                    <InputError class="mt-1.5" :message="form.errors.audio_id" />
                    <p v-if="!audios.length" class="mt-2 text-sm text-[#8A7969]">
                        No published audios are available yet. Publish an audio first.
                    </p>
                </div>

                <div>
                    <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">Sort order</label>
                    <input
                        v-model.number="form.sort_order"
                        type="number"
                        min="0"
                        class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                    />
                    <InputError class="mt-1.5" :message="form.errors.sort_order" />
                    <p class="mt-2 text-xs text-[#A39283]">Lower numbers appear first in the featured row.</p>
                </div>
            </section>

            <div class="space-y-6">
                <section class="space-y-4 rounded-2xl border border-[#EADBC8] bg-white p-5 shadow-sm">
                    <label class="flex items-center gap-2 text-sm text-[#4A3A2C]">
                        <input
                            v-model="form.is_active"
                            type="checkbox"
                            class="rounded border-[#DCC9B2] text-[#B96A2C] focus:ring-[#B96A2C]"
                        />
                        Show on the home page
                    </label>
                    <p class="text-xs text-[#A39283]">
                        Only published audios are shown, even when an entry is active.
                    </p>

                    <button
                        v-if="editing"
                        type="button"
                        class="w-full rounded-lg border border-rose-200 bg-rose-50 px-4 py-2 text-sm font-semibold text-rose-700 transition hover:bg-rose-100"
                        @click="destroy"
                    >
                        Remove from featured
                    </button>
                </section>
            </div>
        </form>
    </AdminLayout>
</template>
