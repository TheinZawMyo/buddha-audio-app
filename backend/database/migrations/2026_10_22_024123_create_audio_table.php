<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('audios', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('teacher_id')->constrained()->restrictOnDelete();
            $table->foreignUuid('audio_type_id')->constrained()->restrictOnDelete();
            $table->string('title');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->string('language', 8)->default('my');
            $table->unsignedInteger('duration_seconds')->default(0);
            $table->string('status')->default('draft');
            $table->timestamp('published_at')->nullable();
            $table->string('audio_path')->nullable();
            $table->string('audio_original_name')->nullable();
            $table->string('audio_mime')->nullable();
            $table->unsignedBigInteger('audio_size')->nullable();
            $table->string('external_playback_url', 2048)->nullable();
            $table->string('cover_path')->nullable();
            $table->string('cover_url', 2048)->nullable();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('updated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['status', 'published_at']);
            $table->index('teacher_id');
            $table->index('audio_type_id');
        });

        Schema::create('audio_audio_category', function (Blueprint $table) {
            $table->foreignUuid('audio_id')->constrained('audios')->cascadeOnDelete();
            $table->foreignUuid('audio_category_id')->constrained()->cascadeOnDelete();

            $table->primary(['audio_id', 'audio_category_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audio_audio_category');
        Schema::dropIfExists('audios');
    }
};
