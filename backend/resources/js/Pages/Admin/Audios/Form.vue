<script setup>
import AdminLayout from '@/Layouts/AdminLayout.vue';
import InputError from '@/Components/InputError.vue';
import StatusBadge from '@/Components/StatusBadge.vue';
import { Head, Link, router, useForm, usePage } from '@inertiajs/vue3';
import Uppy from '@uppy/core';
import Dashboard from '@uppy/dashboard';
import Tus from '@uppy/tus';
import '@uppy/core/css/style.css';
import '@uppy/dashboard/css/style.css';
import { computed, onBeforeUnmount, onMounted, ref } from 'vue';

const props = defineProps({
    audio: Object,
    teachers: Array,
    categories: Array,
    audioTypes: Array,
    audioMaxBytes: Number,
});

const page = usePage();
const editing = computed(() => Boolean(props.audio));
const coverPreview = ref(null);
const audioFileName = ref('');
const selectedAudioUrl = ref(props.audio?.audio_path ? props.audio.playback_url : null);
const uploadingAudio = ref(false);
const audioUploadError = ref('');
const maxAudioBytes = computed(() => props.audioMaxBytes ?? 512000 * 1024);
const maxAudioMb = computed(() => Math.round(maxAudioBytes.value / (1024 * 1024)));
let uppy = null;

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
    audio_upload_path: null,
    audio_original_name: null,
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

const csrfToken = () =>
    document.querySelector('meta[name="csrf-token"]')?.content ?? '';

const discardAudioUpload = async (path) => {
    if (!path) return;

    const response = await fetch(
        route('admin.audios.upload.discard', path.split('/').pop()),
        {
            method: 'DELETE',
            credentials: 'same-origin',
            headers: {
                Accept: 'application/json',
                'X-CSRF-TOKEN': csrfToken(),
            },
        },
    );

    if (!response.ok) {
        throw new Error('Could not remove the previous uploaded file.');
    }
};

const completeAudioUpload = async (uploadId) => {
    const response = await fetch(route('admin.audios.tus.complete', uploadId), {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
            Accept: 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': csrfToken(),
        },
    });

    const result = await response.json().catch(() => ({}));

    if (!response.ok) {
        throw new Error(result.message ?? 'Audio upload could not be completed.');
    }

    return result;
};

const applyUploadedAudio = async (result) => {
    const previousUploadPath = form.audio_upload_path;

    form.audio_upload_path = result.audio_path;
    form.audio_original_name = result.audio_original_name;
    audioFileName.value = result.audio_original_name;
    form.external_playback_url = '';
    selectedAudioUrl.value = result.playback_url;
    audioUploadError.value = '';

    if (previousUploadPath && previousUploadPath !== result.audio_path) {
        try {
            await discardAudioUpload(previousUploadPath);
        } catch {
            // Keep the new upload even if the old pending file could not be removed.
        }
    }
};

const setupUppy = () => {
    uppy = new Uppy({
        autoProceed: true,
        restrictions: {
            maxNumberOfFiles: 1,
            maxFileSize: maxAudioBytes.value,
            allowedFileTypes: ['.mp3', '.wav', '.m4a', '.aac', '.ogg', '.opus', '.webm'],
        },
    });

    uppy.use(Tus, {
        endpoint: route('admin.audios.tus.create'),
        chunkSize: 5 * 1024 * 1024,
        retryDelays: [0, 1000, 3000, 5000, 10000],
        withCredentials: true,
        headers: () => ({
            'X-CSRF-TOKEN': csrfToken(),
            'X-Requested-With': 'XMLHttpRequest',
        }),
    });

    uppy.use(Dashboard, {
        inline: true,
        target: '#audio-uploader',
        height: 220,
        showProgressDetails: true,
        hideUploadButton: true,
        proudlyDisplayPoweredByUppy: false,
        note: `MP3, WAV, M4A, AAC, OGG, OPUS or WEBM · up to ${maxAudioMb.value} MB · resumable`,
    });

    uppy.on('upload', () => {
        uploadingAudio.value = true;
        audioUploadError.value = '';
        form.clearErrors('audio_file');
        form.clearErrors('audio_upload_path');
        form.clearErrors('audio_original_name');
    });

    uppy.on('upload-success', async (file, response) => {
        try {
            const uploadId = response.uploadURL?.split('/').filter(Boolean).pop();

            if (!uploadId) {
                throw new Error('The upload could not be completed.');
            }

            await applyUploadedAudio(await completeAudioUpload(uploadId));
            uppy?.removeFile(file.id);
        } catch (error) {
            audioUploadError.value = error instanceof Error
                ? error.message
                : 'Audio upload failed.';
        } finally {
            uploadingAudio.value = false;
        }
    });

    uppy.on('upload-error', (file, error) => {
        uploadingAudio.value = false;
        audioUploadError.value = error?.message ?? 'Audio upload failed.';
    });

    uppy.on('restriction-failed', (file, error) => {
        audioUploadError.value = error?.message ?? 'This file is not allowed.';
    });
};

onMounted(setupUppy);

onBeforeUnmount(() => {
    uppy?.destroy();
    uppy = null;
});

const removeSelectedAudio = async () => {
    try {
        if (form.audio_upload_path) {
            await discardAudioUpload(form.audio_upload_path);
        }

        form.audio_upload_path = null;
        form.audio_original_name = null;
        selectedAudioUrl.value = props.audio?.audio_path ? props.audio.playback_url : null;
        audioFileName.value = '';
        audioUploadError.value = '';

        if (uppy) {
            uppy.cancelAll();
            uppy.clear();
        }
    } catch (error) {
        audioUploadError.value = error instanceof Error
            ? error.message
            : 'Could not remove the uploaded file.';
    }
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
                    :disabled="form.processing || uploadingAudio"
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
                            <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
                                <div>
                                    <div class="text-sm font-medium text-[#4A3A2C]">Audio file</div>
                                    <div class="text-xs text-[#8A7969]">
                                        {{ form.audio_original_name || audio?.audio_original_name || audioFileName || 'MP3, WAV, M4A, AAC, OGG, OPUS or WEBM' }}
                                    </div>
                                </div>
                                <span class="text-xs text-[#8A7969]">Chunked · resumable</span>
                            </div>
                            <div id="audio-uploader" class="mt-3"></div>
                            <p v-if="uploadingAudio" class="mt-2 text-xs text-[#8A7969]">Uploading audio in chunks…</p>
                            <p v-if="audioFileName && selectedAudioUrl" class="mt-2 text-xs text-emerald-700">Audio saved.</p>
                            <button
                                v-if="form.audio_upload_path"
                                type="button"
                                class="mt-2 text-xs font-medium text-rose-700 underline"
                                @click="removeSelectedAudio"
                            >
                                Remove selected file
                            </button>
                            <InputError
                                class="mt-2"
                                :message="form.errors.audio_file || form.errors.audio_upload_path || form.errors.audio_original_name || audioUploadError"
                            />
                        </div>

                        <div>
                            <label class="mb-1 block text-sm font-medium text-[#4A3A2C]">External playback URL</label>
                            <input
                                :value="selectedAudioUrl || form.external_playback_url"
                                type="url"
                                placeholder="https://cdn.example.com/audio.mp3"
                                :readonly="Boolean(selectedAudioUrl)"
                                @input="form.external_playback_url = $event.target.value"
                                class="block w-full rounded-lg border-[#DCC9B2] px-3 py-2 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                            />
                            <p class="mt-1 text-xs text-[#8A7969]">
                                Selecting an audio file uploads it immediately and displays its playback link here. Otherwise, enter an external URL.
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
