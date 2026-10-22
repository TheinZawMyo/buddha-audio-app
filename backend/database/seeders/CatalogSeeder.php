<?php

namespace Database\Seeders;

use App\Enums\AudioStatus;
use App\Models\Audio;
use App\Models\AudioCategory;
use App\Models\AudioType;
use App\Models\Teacher;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CatalogSeeder extends Seeder
{
    public function run(): void
    {
        $admin = User::query()->where('email', 'admin@example.com')->first();

        DB::transaction(function () use ($admin): void {
            $teachers = $this->seedTeachers();
            $categories = $this->seedCategories();
            $types = $this->seedTypes();

            $audios = [
                [
                    'slug' => 'mind-of-peace',
                    'title' => 'စိတ်၏ ငြိမ်းချမ်းမှု',
                    'description' => 'နေ့စဉ်ဘဝတွင် စိတ်ကို မည်သို့ တည်ငြိမ်အောင်ထားရမည်ကို အသက်ရှူကျင့်စဉ်နှင့်အတူ လေ့လာရန် တရားတော်။',
                    'teacher' => 'u-nanda-mahathera',
                    'type' => 'dhamma-nasind',
                    'categories' => ['dhamma-talks', 'anapanasati'],
                    'duration_seconds' => 372,
                    'cover' => 'https://picsum.photos/seed/audio-1/600/600',
                    'audio' => 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
                ],
                [
                    'slug' => 'four-noble-truths',
                    'title' => 'အလေးပါးသော မြတ်စွာဘုရား၏ တရားတော်',
                    'description' => 'သစ္စာလေးပါးအကြောင်းကို နားလည်လွယ်အောင် ရှင်းလင်းဟောကြားထားသော တရားတော်။',
                    'teacher' => 'u-nanda-mahathera',
                    'type' => 'dhamma-nasind',
                    'categories' => ['dhamma-talks'],
                    'duration_seconds' => 426,
                    'cover' => 'https://picsum.photos/seed/audio-2/600/600',
                    'audio' => 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
                ],
                [
                    'slug' => 'metta-bhavana',
                    'title' => 'မေတ္တာဘာဝနာ ကျင့်စဉ်',
                    'description' => 'မေတ္တာဓာတ်ကို အမျိုးသား/အမျိုးသမီး အလိုက် ကျင့်ကြံနိုင်ရန် လမ်းညွှန်ချက်။',
                    'teacher' => 'u-nanda-mahathera',
                    'type' => 'dhamma-nasind',
                    'categories' => ['dhamma-talks', 'anapanasati'],
                    'duration_seconds' => 480,
                    'cover' => 'https://picsum.photos/seed/audio-3/600/600',
                    'audio' => 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
                ],
                [
                    'slug' => 'ratanasutta',
                    'title' => 'ရတနာသုတ်',
                    'description' => 'ရတနာသုတ် ပရိတ်တော်ကို တည်ငြိမ်စွာ ရွတ်ဖတ်ထားခြင်း။',
                    'teacher' => 'ashin-thuwanna',
                    'type' => 'chanting',
                    'categories' => ['paritta', 'gatha'],
                    'duration_seconds' => 540,
                    'cover' => 'https://picsum.photos/seed/audio-4/600/600',
                    'audio' => 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
                ],
                [
                    'slug' => 'karaniya-metta',
                    'title' => 'ကရဏာသီယ မေတ္တာသုတ်',
                    'description' => 'မေတ္တာသုတ်ပရိတ်တော် ရွတ်ဖတ်ခြင်း။',
                    'teacher' => 'ashin-thuwanna',
                    'type' => 'chanting',
                    'categories' => ['paritta'],
                    'duration_seconds' => 300,
                    'cover' => 'https://picsum.photos/seed/audio-5/600/600',
                    'audio' => 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
                ],
                [
                    'slug' => 'mangala-sutta',
                    'title' => 'မင်္ဂလာသုတ်',
                    'description' => 'မင်္ဂလာသုတ်ကို ဖြေးညှင်းစွာ ရွတ်ဖတ်ထားသော အသံဖိုင်။',
                    'teacher' => 'ashin-thuwanna',
                    'type' => 'chanting',
                    'categories' => ['paritta', 'gatha'],
                    'duration_seconds' => 336,
                    'cover' => 'https://picsum.photos/seed/audio-6/600/600',
                    'audio' => 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
                ],
                [
                    'slug' => 'patthana-intro',
                    'title' => 'ပဋ္ဌာန်း အခြေခံ (အပိုင်း ၁)',
                    'description' => 'ပဋ္ဌာန်းကျမ်း၏ အဓိပ္ပာယ်ဖွင့်ဆိုချက်နှင့် အခြေခံသဘောတရားများ။',
                    'teacher' => 'u-kavi-bhivamsa',
                    'type' => 'study',
                    'categories' => ['patthana', 'dhamma-talks'],
                    'duration_seconds' => 600,
                    'cover' => 'https://picsum.photos/seed/audio-7/600/600',
                    'audio' => 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
                ],
                [
                    'slug' => 'patthana-intro-2',
                    'title' => 'ပဋ္ဌာန်း အခြေခံ (အပိုင်း ၂)',
                    'description' => 'အကြောင်းအကျိုး သဟဇာတဖြစ်မှုကို ဥပမာဖြင့် ရှင်းလင်းဆွေးနွေးချက်။',
                    'teacher' => 'u-kavi-bhivamsa',
                    'type' => 'discussion',
                    'categories' => ['patthana'],
                    'duration_seconds' => 624,
                    'cover' => 'https://picsum.photos/seed/audio-8/600/600',
                    'audio' => 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
                ],
                [
                    'slug' => 'anapanasati-basics',
                    'title' => 'အသက်ရှူကျင့်စဉ် အခြေခံ',
                    'description' => 'အသက်ရှူကို သတိထားရှုခြင်းဖြင့် စိတ်ကို စုစည်းနည်း။',
                    'teacher' => 'u-nanda-mahathera',
                    'type' => 'dhamma-nasind',
                    'categories' => ['anapanasati', 'dhamma-talks'],
                    'duration_seconds' => 512,
                    'cover' => 'https://picsum.photos/seed/audio-9/600/600',
                    'audio' => 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
                ],
                [
                    'slug' => 'five-precepts',
                    'title' => 'သီလငါးပါး အဓိပ္ပာယ်',
                    'description' => 'သီလငါးပါးကို နေ့စဉ်ဘဝတွင် မည်သို့ကျင့်ကြံရမည်။',
                    'teacher' => 'u-kavi-bhivamsa',
                    'type' => 'discussion',
                    'categories' => ['dhamma-talks'],
                    'duration_seconds' => 450,
                    'cover' => 'https://picsum.photos/seed/audio-10/600/600',
                    'audio' => 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
                ],
                [
                    'slug' => 'buddha-gatha',
                    'title' => 'မြတ်စွာဘုရား ဂုဏ်တော်',
                    'description' => 'ဂုဏ်တော်များကို သီဆိုရွတ်ဖတ်ထားခြင်း။',
                    'teacher' => 'ashin-thuwanna',
                    'type' => 'chanting',
                    'categories' => ['gatha'],
                    'duration_seconds' => 288,
                    'cover' => 'https://picsum.photos/seed/audio-11/600/600',
                    'audio' => 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',
                ],
                [
                    'slug' => 'three-refuges',
                    'title' => 'ရတနာသုံးပါး ခိုလှုံခြင်း',
                    'description' => 'ဘုရား၊ တရား၊ သံဃာ ရတနာသုံးပါးကို ခိုလှုံရာ ပရိတ်တော်။',
                    'teacher' => 'ashin-thuwanna',
                    'type' => 'chanting',
                    'categories' => ['paritta'],
                    'duration_seconds' => 240,
                    'cover' => 'https://picsum.photos/seed/audio-12/600/600',
                    'audio' => 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',
                ],
            ];

            foreach ($audios as $index => $item) {
                $audio = Audio::query()->updateOrCreate(
                    ['slug' => $item['slug']],
                    [
                        'teacher_id' => $teachers[$item['teacher']]->id,
                        'audio_type_id' => $types[$item['type']]->id,
                        'title' => $item['title'],
                        'description' => $item['description'],
                        'language' => 'my',
                        'duration_seconds' => $item['duration_seconds'],
                        'status' => AudioStatus::Published,
                        'published_at' => now()->subDays($index + 1),
                        'external_playback_url' => $item['audio'],
                        'cover_url' => $item['cover'],
                        'created_by' => $admin?->id,
                        'updated_by' => $admin?->id,
                    ],
                );

                $audio->categories()->sync(
                    collect($item['categories'])->map(fn (string $slug) => $categories[$slug]->id)->all(),
                );
            }
        });
    }

    /**
     * @return array<string, Teacher>
     */
    private function seedTeachers(): array
    {
        $teachers = [
            'u-nanda-mahathera' => [
                'name' => 'ဆရာတော် ဦးနန္ဒမဟာသာ',
                'short_name' => 'ဦးနန္ဒမဟာသာ',
                'bio' => 'သီတာတော် ဓမ္မစကြာနယ်မြေ၊ တရားဟော/တရားသင်ကြားခြင်း။',
                'photo_url' => 'https://picsum.photos/seed/teacher-nanda/240/240',
                'sort_order' => 1,
            ],
            'ashin-thuwanna' => [
                'name' => 'အရှင်သုဝဏ္ဏ',
                'short_name' => 'အရှင်သုဝဏ္ဏ',
                'bio' => 'ပရိတ်တရားတော်များ၊ ဂုဏ်တော်ရွတ်ဖတ်ခြင်း။',
                'photo_url' => 'https://picsum.photos/seed/teacher-thuwanna/240/240',
                'sort_order' => 2,
            ],
            'u-kavi-bhivamsa' => [
                'name' => 'ဦးကဝိဘိဝံသ',
                'short_name' => 'ဦးကဝိဘိဝံသ',
                'bio' => 'ပဋ္ဌာန်း/အဘိဓမ္မ လေ့လာဆွေးနွေးပွဲများ။',
                'photo_url' => 'https://picsum.photos/seed/teacher-kavi/240/240',
                'sort_order' => 3,
            ],
        ];

        $result = [];

        foreach ($teachers as $slug => $attributes) {
            $result[$slug] = Teacher::query()->updateOrCreate(
                ['slug' => $slug],
                [...$attributes, 'is_active' => true],
            );
        }

        return $result;
    }

    /**
     * @return array<string, AudioCategory>
     */
    private function seedCategories(): array
    {
        $categories = [
            'dhamma-talks' => ['name' => 'တရားတော်', 'sort_order' => 1],
            'paritta' => ['name' => 'ပရိတ်', 'sort_order' => 2],
            'patthana' => ['name' => 'ပဋ္ဌာန်း', 'sort_order' => 3],
            'anapanasati' => ['name' => 'အသက်ရှူကျင့်စဉ်', 'sort_order' => 4],
            'gatha' => ['name' => 'ဂုဏ်တော်', 'sort_order' => 5],
        ];

        $result = [];

        foreach ($categories as $slug => $attributes) {
            $result[$slug] = AudioCategory::query()->updateOrCreate(
                ['slug' => $slug],
                [...$attributes, 'is_active' => true],
            );
        }

        return $result;
    }

    /**
     * @return array<string, AudioType>
     */
    private function seedTypes(): array
    {
        $types = [
            'dhamma-nasind' => ['name' => 'တရားနာ', 'sort_order' => 1],
            'chanting' => ['name' => 'ရွတ်ဖတ်', 'sort_order' => 2],
            'discussion' => ['name' => 'ဆွေးနွေး', 'sort_order' => 3],
            'study' => ['name' => 'လေ့လာ', 'sort_order' => 4],
        ];

        $result = [];

        foreach ($types as $slug => $attributes) {
            $result[$slug] = AudioType::query()->updateOrCreate(
                ['slug' => $slug],
                [...$attributes, 'is_active' => true],
            );
        }

        return $result;
    }
}
