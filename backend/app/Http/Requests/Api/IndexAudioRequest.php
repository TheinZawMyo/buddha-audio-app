<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;

class IndexAudioRequest extends FormRequest
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
            'query' => ['nullable', 'string', 'max:100'],
            'teacher' => ['nullable', 'string', 'max:255'],
            'category' => ['nullable', 'string', 'max:255'],
            'type' => ['nullable', 'string', 'max:255'],
            'cursor' => ['nullable', 'string', 'max:2048'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:50'],
        ];
    }

    /**
     * @return array{query: string|null, teacher: string|null, category: string|null, type: string|null, cursor: string|null, limit: int}
     */
    public function filters(): array
    {
        return [
            'query' => $this->string('query')->trim()->toString() ?: null,
            'teacher' => $this->string('teacher')->trim()->toString() ?: null,
            'category' => $this->string('category')->trim()->toString() ?: null,
            'type' => $this->string('type')->trim()->toString() ?: null,
            'cursor' => $this->string('cursor')->toString() ?: null,
            'limit' => $this->integer('limit', 20),
        ];
    }
}
