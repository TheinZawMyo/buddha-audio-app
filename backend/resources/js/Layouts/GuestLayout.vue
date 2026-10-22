<script setup>
import ApplicationLogo from '@/Components/ApplicationLogo.vue';
import { Link } from '@inertiajs/vue3';
</script>

<template>
    <div class="flex min-h-screen flex-col items-center justify-center bg-[#FFF8EE] px-4 py-10">
        <div class="w-full max-w-md">
            <div class="mb-8 flex flex-col items-center text-center">
                <Link href="/" class="flex flex-col items-center gap-3">
                    <div class="grid h-16 w-16 place-items-center rounded-full bg-[#70401F] text-2xl font-bold text-white">
                        ဓ
                    </div>
                    <div>
                        <div class="text-lg font-semibold text-[#28231F]">Buddha Audio</div>
                        <div class="text-sm text-[#7A6A5B]">Dhamma catalog admin</div>
                    </div>
                </Link>
            </div>

            <div class="rounded-2xl border border-[#EADBC8] bg-white p-6 shadow-xl shadow-[#70401F]/5 sm:p-8">
                <slot />
            </div>

            <p class="mt-6 text-center text-xs text-[#8A7969]">
                Published content is served to the listener app over the public API.
            </p>
        </div>
    </div>
</template>
