<script setup>
import AdminLayout from '@/Layouts/AdminLayout.vue';
import InputError from '@/Components/InputError.vue';
import StatusBadge from '@/Components/StatusBadge.vue';
import { Head, Link, router, useForm, usePage } from '@inertiajs/vue3';
import { computed, ref } from 'vue';

const props = defineProps({
    audio: Object,
    teachers: Array,
    categories: Array,
    audioTypes: Array,
});

const page = usePage();
const editing = computed(() => Boolean(props.audio));
const coverPreview = ref(null);
const audioFileName = ref('');

const form = useForm({
    title: props.audio?.title ?? '',
    slug: props.audio?.slug ?? '',
    description: props.audio?.description ?? '',
    teacher_id: props.audio?.teacher_id ?? '',
    audio_type_id: props.audio?.audio_type_id ?? '',
    categories: props.audio?.categories?.map((category) => category.id) ?? [],
    language: props.audio?.language ?? 'my',
    duration_seconds: props.audio?.duration_seconds ?? 0,
    external_playback_url: props.audio?.external_playback_url ?? '',
    audio_file: null,
    cover_image: null,
});

const currentCover = computed(() => coverPreview.value ?? props.audio?.cover_image_url ?? null);

const chooseCover = (event) => {
    const file = event.target.files[0] ?? null;
    form.cover_image = file;

    if (file) {
        coverPreview.value = URL.createObjectURL(file);
    }
};

const chooseAudio = (event) => {
    const file = event.target.files[0] ?? null;
    form.audio_file = file;
    audioFileName.value = file?.name ?? '';
};

const submit = () => {
    if (editing.value) {
        form.put(route('admin.audios.update', props.audio.slug), { forceFormData: true, preserveScroll: true });
        return;
    }

    form.post(route('admin.audios.store'), { forceFormData: true, preserveScroll: true });
};

const publish = () => {
    router.post(route('admin.audios.publish', props.audio.slug), {}, { preserveScroll: true });
};

const archive = () => {
    if (confirm('Archive this audio? It will be removed from the public catalog.')) {
        router.post(route('admin.audios.archive', props.audio.slug), {}, { preserveScroll: true });
    }
};

const destroy = () => {
    if (confirm(`Delete "${props.audio.title}"?`)) {
        router.delete(route('admin.audios.destroy', props.audio.slug));
    }
};
</script>

<template>
    <AdminLayout>
        <Head :title="editing ? 'Edit audio' : 'New audio'" />

        <template #header>
            <div class="min-w-0">
                <div class="flex items-center gap-3">
                    <h1 class="truncate text-lg font-semibold text-[#28231F]">
                        {{ editing ? 'Edit audio' : 'New audio' }}
                    </h1>
                    <StatusBadge v-if="editing" :status="audio.status" />
                </div>
                <p class="truncate text-sm text-[#7A6A5B]">
                    {{ editing ? audio.title : 'Create a draft, upload the recording, then publish.' }}
                </p>
            </div>
            <div class="flex shrink-0 items-center gap-2">
                <Link
                    :href="route('admin.audios.index')"
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
                    {{ editing ? 'Save changes' : 'Save draft' }}
                </button>
            </div>
        </template>

        <div
            v-if="page.props.errors.publish"
            class="mb-5 rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-800"
        >
            {{ page.props.errors.publish }}
        </div>

        <form class="grid gap-6 xl:grid-cols-3" @submit.prevent="submit">
            <div class="space-y-6 xl:col-span-2">
                <section class="rounded-2xl border border-[#EADBC8] bg-white p-5 shadow-sm">
                    <h2 class="text-sm font-semibold">Metadata</h2>
                    <div class="mt-4 grid gap-4 sm:grid-cols-2">
                        <div class="sm:col-span-2">
                            <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">Title</label>
                            <input
                                v-model="form.title"
                                type="text"
                                class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                            />
                            <InputError class="mt-1.5" :message="form.errors.title" />
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
                            <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">Language</label>
                            <input
                                v-model="form.language"
                                type="text"
                                maxlength="8"
                                class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                            />
                            <InputError class="mt-1.5" :message="form.errors.language" />
                        </div>

                        <div class="sm:col-span-2">
                            <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">Description</label>
                            <textarea
                                v-model="form.description"
                                rows="4"
                                class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                            />
                            <InputError class="mt-1.5" :message="form.errors.description" />
                        </div>
                    </div>
                </section>

                <section class="rounded-2xl border border-[#EADBC8] bg-white p-5 shadow-sm">
                    <h2 class="text-sm font-semibold">Classification</h2>
                    <div class="mt-4 grid gap-4 sm:grid-cols-2">
                        <div>
                            <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">Teacher</label>
                            <select
                                v-model="form.teacher_id"
                                class="block w-full rounded-lg border-[#DCC9B2] bg-white px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                            >
                                <option value="">Select a teacher</option>
                                <option v-for="teacher in teachers" :key="teacher.id" :value="teacher.id">
                                    {{ teacher.name }}
                                </option>
                            </select>
                            <InputError class="mt-1.5" :message="form.errors.teacher_id" />
                        </div>

                        <div>
                            <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">Audio type</label>
                            <select
                                v-model="form.audio_type_id"
                                class="block w-full rounded-lg border-[#DCC9B2] bg-white px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                            >
                                <option value="">Select a type</option>
                                <option v-for="type in audioTypes" :key="type.id" :value="type.id">
                                    {{ type.name }}
                                </option>
                            </select>
                            <InputError class="mt-1.5" :message="form.errors.audio_type_id" />
                        </div>

                        <div class="sm:col-span-2">
                            <label class="mb-2 block text-sm font-medium text-[#4A3A2C]">Categories</label>
                            <div class="flex flex-wrap gap-2">
                                <label
                                    v-for="category in categories"
                                    :key="category.id"
                                    class="inline-flex cursor-pointer items-center gap-2 rounded-full border px-3 py-1.5 text-xs font-medium transition"
                                    :class="
                                        form.categories.includes(category.id)
                                            ? 'border-[#B96A2C] bg-[#B96A2C]/10 text-[#8B4D1D]'
                                            : 'border-[#DCC9B2] text-[#6B5A4C]'
                                    "
                                >
                                    <input
                                        v-model="form.categories"
                                        type="checkbox"
                                        :value="category.id"
                                        class="sr-only"
                                    />
                                    {{ category.name }}
                                </label>
                            </div>
                            <InputError class="mt-1.5" :message="form.errors.categories" />
                        </div>
                    </div>
                </section>

                <section class="rounded-2xl border border-[#EADBC8] bg-white p-5 shadow-sm">
                    <h2 class="text-sm font-semibold">Media</h2>
                    <div class="mt-4 space-y-4">
                        <div class="rounded-xl border border-dashed border-[#DCC9B2] bg-[#FFFBF5] p-4">
                            <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
                                <div>
                                    <div class="text-sm font-medium text-[#4A3A2C]">Audio file</div>
                                    <div class="text-xs text-[#8A7969]">
                                        {{ audio?.audio_original_name || audioFileName || 'MP3, WAV, M4A, AAC, OGG, OPUS or WEBM' }}
                                    </div>
                                </div>
                                <input
                                    type="file"
                                    accept=".mp3,.wav,.m4a,.aac,.ogg,.opus,.webm"
                                    class="block text-sm text-[#6B5A4C] file:mr-3 file:rounded-md file:border-0 file:bg-[#70401F] file:px-3 file:py-2 file:text-xs file:font-semibold file:text-white"
                                    @change="chooseAudio"
                                />
                            </div>
                            <InputError class="mt-2" :message="form.errors.audio_file" />
                        </div>

                        <div>
                            <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">External playback URL</label>
                            <input
                                v-model="form.external_playback_url"
                                type="url"
                                placeholder="https://cdn.example.com/audio.mp3"
                                class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                            />
                            <p class="mt-1 text-xs text-[#8A7969]">
                                Used when no private upload is present. Uploaded files are served through short-lived signed URLs.
                            </p>
                            <InputError class="mt-1.5" :message="form.errors.external_playback_url" />
                        </div>

                        <div>
                            <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">Duration (seconds)</label>
                            <input
                                v-model.number="form.duration_seconds"
                                type="number"
                                min="0"
                                max="86400"
                                class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C] sm:w-48"
                            />
                            <InputError class="mt-1.5" :message="form.errors.duration_seconds" />
                        </div>
                    </div>
                </section>
            </div>

            <div class="space-y-6">
                <section class="rounded-2xl border border-[#EADBC8] bg-white p-5 shadow-sm">
                    <h2 class="text-sm font-semibold">Cover image</h2>
                    <div class="mt-4 overflow-hidden rounded-xl border border-[#EADBC8] bg-[#F3E7D7]">
                        <img v-if="currentCover" :src="currentCover" alt="Cover preview" class="aspect-square w-full object-cover" />
                        <div v-else class="grid aspect-square place-items-center text-sm text-[#A39283]">
                            No cover
                        </div>
                    </div>
                    <input
                        type="file"
                        accept="image/jpeg,image/png,image/webp"
                        class="mt-3 block w-full text-sm text-[#6B5A4C] file:mr-3 file:rounded-md file:border-0 file:bg-[#70401F] file:px-3 file:py-2 file:text-xs file:font-semibold file:text-white"
                        @change="chooseCover"
                    />
                    <InputError class="mt-2" :message="form.errors.cover_image" />
                </section>

                <section v-if="editing" class="rounded-2xl border border-[#EADBC8] bg-white p-5 shadow-sm">
                    <h2 class="text-sm font-semibold">Publishing</h2>
                    <p class="mt-2 text-xs text-[#8A7969]">
                        A published audio must have a playable asset and a duration of at least one second.
                    </p>
                    <div class="mt-4 space-y-2">
                        <button
                            v-if="audio.status !== 'published'"
                            type="button"
                            class="w-full rounded-lg bg-emerald-600 px-4 py-2 text-sm font-semibold text-white transition hover:bg-emerald-700"
                            @click="publish"
                        >
                            Publish audio
                        </button>
                        <button
                            v-if="audio.status === 'published'"
                            type="button"
                            class="w-full rounded-lg border border-amber-300 bg-amber-50 px-4 py-2 text-sm font-semibold text-amber-800 transition hover:bg-amber-100"
                            @click="archive"
                        >
                            Archive audio
                        </button>
                        <a
                            v-if="audio.playback_url"
                            :href="audio.playback_url"
                            target="_blank"
                            rel="noopener"
                            class="block rounded-lg border border-[#DCC9B2] px-4 py-2 text-center text-sm font-medium text-[#6B5A4C] transition hover:border-[#B96A2C]"
                        >
                            Open playback URL
                        </a>
                        <button
                            type="button"
                            class="w-full rounded-lg border border-rose-200 bg-rose-50 px-4 py-2 text-sm font-semibold text-rose-700 transition hover:bg-rose-100"
                            @click="destroy"
                        >
                            Delete audio
                        </button>
                    </div>
                </section>

                <section class="rounded-2xl border border-[#EADBC8] bg-[#FFFBF5] p-5 text-xs leading-relaxed text-[#7A6A5B]">
                    Drafts are not exposed by the public API. Publish only after checking the teacher, type and categories.
                </section>
            </div>
        </form>
    </AdminLayout>
</template>
