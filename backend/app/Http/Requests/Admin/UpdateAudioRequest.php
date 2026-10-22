<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class UpdateAudioRequest extends FormRequest
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
            'title' => ['required', 'string', 'max:255'],
            'slug' => ['nullable', 'string', 'max:255', 'alpha_dash'],
            'description' => ['nullable', 'string', 'max:20000'],
            'teacher_id' => ['required', 'uuid', 'exists:teachers,id'],
            'audio_type_id' => ['required', 'uuid', 'exists:audio_types,id'],
            'categories' => ['nullable', 'array'],
            'categories.*' => ['uuid', 'exists:audio_categories,id'],
            'language' => ['required', 'string', 'max:8'],
            'duration_seconds' => ['required', 'integer', 'min:0', 'max:86400'],
            'audio_file' => ['nullable', 'file', 'mimes:mp3,wav,m4a,aac,ogg,opus,webm', 'max:512000'],
            'cover_image' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:4096'],
            'external_playback_url' => ['nullable', 'url', 'max:2048'],
        ];
    }
}
