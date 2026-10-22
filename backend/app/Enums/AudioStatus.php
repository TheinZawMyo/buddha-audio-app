<?php

namespace App\Enums;

enum AudioStatus: string
{
    case Draft = 'draft';
    case Processing = 'processing';
    case Published = 'published';
    case Archived = 'archived';

    public function label(): string
    {
        return match ($this) {
            self::Draft => 'Draft',
            self::Processing => 'Processing',
            self::Published => 'Published',
            self::Archived => 'Archived',
        };
    }

    public function badgeClasses(): string
    {
        return match ($this) {
            self::Draft => 'bg-slate-100 text-slate-700',
            self::Processing => 'bg-amber-100 text-amber-800',
            self::Published => 'bg-emerald-100 text-emerald-800',
            self::Archived => 'bg-rose-100 text-rose-700',
        };
    }

    /**
     * @return array<int, string>
     */
    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
