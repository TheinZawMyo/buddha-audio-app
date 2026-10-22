<script setup>
import GuestLayout from '@/Layouts/GuestLayout.vue';
import InputError from '@/Components/InputError.vue';
import { Head, useForm } from '@inertiajs/vue3';

defineProps({
    canResetPassword: {
        type: Boolean,
    },
    status: {
        type: String,
    },
});

const form = useForm({
    email: '',
    password: '',
    remember: false,
});

const submit = () => {
    form.post(route('login'), {
        onFinish: () => form.reset('password'),
    });
};
</script>

<template>
    <GuestLayout>
        <Head title="Admin sign in" />

        <div class="mb-6">
            <h1 class="text-xl font-semibold text-[#28231F]">Admin sign in</h1>
            <p class="mt-1 text-sm text-[#7A6A5B]">Manage audios, teachers and catalog taxonomy.</p>
        </div>

        <div v-if="status" class="mb-4 rounded-lg bg-emerald-50 px-3 py-2 text-sm font-medium text-emerald-700">
            {{ status }}
        </div>

        <form @submit.prevent="submit" class="space-y-5">
            <div>
                <label for="email" class="mb-1 block text-sm font-medium text-[#4A3A2C]">Email</label>
                <input
                    id="email"
                    type="email"
                    v-model="form.email"
                    required
                    autofocus
                    autocomplete="username"
                    class="block w-full rounded-lg border-[#DCC9B2] bg-white px-3 py-2.5 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                />
                <InputError class="mt-1.5" :message="form.errors.email" />
            </div>

            <div>
                <label for="password" class="mb-1 block text-sm font-medium text-[#4A3A2C]">Password</label>
                <input
                    id="password"
                    type="password"
                    v-model="form.password"
                    required
                    autocomplete="current-password"
                    class="block w-full rounded-lg border-[#DCC9B2] bg-white px-3 py-2.5 text-sm shadow-sm focus:border-[#B96A2C] focus:ring-[#B96A2C]"
                />
                <InputError class="mt-1.5" :message="form.errors.password" />
            </div>

            <label class="flex items-center gap-2 text-sm text-[#6B5A4C]">
                <input
                    type="checkbox"
                    v-model="form.remember"
                    class="rounded border-[#DCC9B2] text-[#B96A2C] focus:ring-[#B96A2C]"
                />
                Remember me
            </label>

            <button
                type="submit"
                :disabled="form.processing"
                class="inline-flex w-full items-center justify-center rounded-lg bg-[#B96A2C] px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-[#A25A24] focus:outline-none focus:ring-2 focus:ring-[#B96A2C] focus:ring-offset-2 disabled:opacity-60"
            >
                Sign in
            </button>
        </form>
    </GuestLayout>
</template>
