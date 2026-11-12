<?php

namespace App\Http\Requests\Admin;

use App\Enums\AudioStatus;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateFeaturedAudioRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'audio_id' => [
                'required',
                'uuid',
                Rule::exists('audios', 'id')->where('status', AudioStatus::Published->value),
                Rule::unique('featured_audios', 'audio_id')->ignore($this->route('featuredAudio')?->id),
            ],
            'sort_order' => ['nullable', 'integer', 'min:0', 'max:100000'],
            'is_active' => ['boolean'],
        ];
    }
}
