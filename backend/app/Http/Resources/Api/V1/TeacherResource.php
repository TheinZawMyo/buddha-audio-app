<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TeacherResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'slug' => $this->slug,
            'name' => $this->name,
            'short_name' => $this->short_name,
            'bio' => $this->bio,
            'photo_url' => $this->photo_url,
            'sort_order' => (int) $this->sort_order,
            'is_active' => (bool) $this->is_active,
        ];
    }
}
