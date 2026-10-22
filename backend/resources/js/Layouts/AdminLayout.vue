<script setup>
import { computed } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';
import FlashMessage from '@/Components/FlashMessage.vue';

const page = usePage();
const user = computed(() => page.props.auth.user);
const initials = computed(() => {
    const name = user.value?.name ?? 'Admin';

    return name
        .split(' ')
        .filter(Boolean)
        .slice(0, 2)
        .map((part) => part.charAt(0).toUpperCase())
        .join('');
});

const navigation = [
    { label: 'Dashboard', route: 'admin.dashboard', pattern: 'admin.dashboard' },
    { label: 'Audios', route: 'admin.audios.index', pattern: 'admin.audios.*' },
    { label: 'Teachers', route: 'admin.teachers.index', pattern: 'admin.teachers.*' },
    { label: 'Categories', route: 'admin.categories.index', pattern: 'admin.categories.*' },
    { label: 'Audio types', route: 'admin.audio-types.index', pattern: 'admin.audio-types.*' },
    { label: 'Audit logs', route: 'admin.audit-logs.index', pattern: 'admin.audit-logs.*' },
];

const isActive = (pattern) => route().current(pattern);
</script>

<template>
    <div class="min-h-screen bg-[#FFF8EE] text-[#28231F]">
        <aside class="fixed inset-y-0 left-0 z-40 hidden w-64 flex-col bg-[#70401F] text-white md:flex">
            <div class="flex items-center gap-3 border-b border-white/10 px-6 py-6">
                <div class="grid h-10 w-10 place-items-center rounded-full bg-[#B96A2C] text-lg font-bold">
                    ဓ
                </div>
                <div>
                    <div class="text-sm font-semibold leading-tight">Buddha Audio</div>
                    <div class="text-xs text-white/60">Admin console</div>
                </div>
            </div>

            <nav class="flex-1 space-y-1 overflow-y-auto px-3 py-5">
                <div class="px-3 pb-2 text-[11px] font-semibold uppercase tracking-widest text-white/40">
                    Catalog
                </div>
                <Link
                    v-for="item in navigation"
                    :key="item.route"
                    :href="route(item.route)"
                    class="flex items-center rounded-lg px-3 py-2.5 text-sm font-medium transition"
                    :class="
                        isActive(item.pattern)
                            ? 'bg-white/15 text-white shadow-sm'
                            : 'text-white/75 hover:bg-white/10 hover:text-white'
                    "
                >
                    {{ item.label }}
                </Link>
            </nav>

            <div class="border-t border-white/10 p-4">
                <div class="mb-3 flex items-center gap-3">
                    <div class="grid h-9 w-9 place-items-center rounded-full bg-white/15 text-xs font-semibold">
                        {{ initials }}
                    </div>
                    <div class="min-w-0">
                        <div class="truncate text-sm font-medium">{{ user?.name }}</div>
                        <div class="truncate text-xs text-white/50">{{ user?.role }}</div>
                    </div>
                </div>
                <Link
                    :href="route('logout')"
                    method="post"
                    as="button"
                    class="w-full rounded-lg border border-white/20 px-3 py-2 text-xs font-semibold uppercase tracking-wide text-white/80 transition hover:bg-white/10 hover:text-white"
                >
                    Log out
                </Link>
            </div>
        </aside>

        <div class="md:pl-64">
            <div class="sticky top-0 z-30 bg-[#70401F] text-white md:hidden">
                <div class="flex items-center justify-between px-4 py-3">
                    <div class="flex items-center gap-2">
                        <div class="grid h-8 w-8 place-items-center rounded-full bg-[#B96A2C] text-sm font-bold">
                            ဓ
                        </div>
                        <span class="text-sm font-semibold">Buddha Audio</span>
                    </div>
                    <Link :href="route('logout')" method="post" as="button" class="text-xs text-white/80">
                        Log out
                    </Link>
                </div>
                <nav class="flex gap-1 overflow-x-auto px-3 pb-2">
                    <Link
                        v-for="item in navigation"
                        :key="item.route"
                        :href="route(item.route)"
                        class="whitespace-nowrap rounded-md px-3 py-1.5 text-xs font-medium"
                        :class="isActive(item.pattern) ? 'bg-white/20' : 'text-white/70'"
                    >
                        {{ item.label }}
                    </Link>
                </nav>
            </div>

            <header class="border-b border-[#EADBC8] bg-[#FFFDF9]/90 px-4 py-5 backdrop-blur sm:px-6 lg:px-8">
                <div class="mx-auto flex max-w-7xl items-center justify-between gap-4">
                    <slot name="header" />
                </div>
            </header>

            <main class="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
                <FlashMessage />
                <slot />
            </main>
        </div>
    </div>
</template>
