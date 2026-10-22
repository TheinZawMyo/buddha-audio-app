<script setup>
import { Link } from '@inertiajs/vue3';

defineProps({
    paginator: {
        type: Object,
        required: true,
    },
});
</script>

<template>
    <div
        v-if="paginator.links && paginator.links.length > 3"
        class="mt-5 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between"
    >
        <p class="text-xs text-[#6B5A4C]">
            Showing <span class="font-semibold">{{ paginator.from ?? 0 }}</span>
            to <span class="font-semibold">{{ paginator.to ?? 0 }}</span>
            of <span class="font-semibold">{{ paginator.total }}</span>
        </p>
        <nav class="flex flex-wrap gap-1">
            <template v-for="(link, index) in paginator.links" :key="index">
                <Link
                    v-if="link.url"
                    :href="link.url"
                    preserve-scroll
                    class="rounded-md border px-3 py-1.5 text-xs font-medium transition"
                    :class="
                        link.active
                            ? 'border-[#B96A2C] bg-[#B96A2C] text-white'
                            : 'border-[#E6D6C3] bg-white text-[#5C4633] hover:border-[#B96A2C] hover:text-[#B96A2C]'
                    "
                    v-html="link.label"
                />
                <span
                    v-else
                    class="rounded-md border border-[#E6D6C3] bg-[#F7EFE4] px-3 py-1.5 text-xs text-[#B3A08D]"
                    v-html="link.label"
                />
            </template>
        </nav>
    </div>
</template>
