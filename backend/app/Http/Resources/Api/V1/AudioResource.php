<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AudioResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'slug' => $this->slug,
            'title' => $this->title,
            'description' => $this->description,
            'teacher' => TeacherResource::make($this->teacher)->resolve($request),
            'type' => AudioTypeResource::make($this->audioType)->resolve($request),
            'categories' => AudioCategoryResource::collection($this->categories)->resolve($request),
            'duration_seconds' => (int) $this->duration_seconds,
            'language' => $this->language,
            'cover_image_url' => $this->cover_image_url,
            'playback_url' => $this->playback_url,
            'published_at' => $this->published_at?->toIso8601String(),
        ];
    }
}
