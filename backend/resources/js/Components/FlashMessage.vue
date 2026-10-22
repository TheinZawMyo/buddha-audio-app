<script setup>
import { usePage } from '@inertiajs/vue3';
import { computed } from 'vue';

const page = usePage();
const success = computed(() => page.props.flash?.success);
const error = computed(() => page.props.flash?.error);
</script>

<template>
    <div v-if="success" class="mb-5 rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-800">
        {{ success }}
    </div>
    <div v-if="error" class="mb-5 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
        {{ error }}
    </div>
</template>
