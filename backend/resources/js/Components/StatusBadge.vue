<script setup>
defineProps({
    status: {
        type: String,
        required: true,
    },
});

const classes = {
    draft: 'bg-slate-100 text-slate-700 ring-slate-200',
    processing: 'bg-amber-100 text-amber-800 ring-amber-200',
    published: 'bg-emerald-100 text-emerald-800 ring-emerald-200',
    archived: 'bg-rose-100 text-rose-700 ring-rose-200',
};

const labels = {
    draft: 'Draft',
    processing: 'Processing',
    published: 'Published',
    archived: 'Archived',
};
</script>

<template>
    <span
        class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold capitalize ring-1 ring-inset"
        :class="classes[status] ?? classes.draft"
    >
        {{ labels[status] ?? status }}
    </span>
</template>
