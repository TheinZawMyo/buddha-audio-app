<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class TusAudioUploadTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = User::factory()->admin()->create();
        Storage::fake(config('catalog.audio_disk'));
    }

    public function test_tus_upload_can_be_created_chunked_and_completed(): void
    {
        $location = $this->createUpload('talk.mp3', 'audio/mpeg', 11);

        $this->sendHead($location)
            ->assertOk()
            ->assertHeader('Tus-Resumable', '1.0.0')
            ->assertHeader('Upload-Offset', '0')
            ->assertHeader('Upload-Length', '11');

        $this->sendPatch($location, 0, 'hello')
            ->assertStatus(204)
            ->assertHeader('Upload-Offset', '5');

        $this->sendPatch($location, 5, ' world')
            ->assertStatus(204)
            ->assertHeader('Upload-Offset', '11');

        $id = basename(parse_url($location, PHP_URL_PATH));

        $response = $this->actingAs($this->admin)
            ->postJson(route('admin.audios.tus.complete', ['upload' => $id]))
            ->assertOk()
            ->assertJsonStructure(['audio_path', 'audio_original_name', 'audio_mime', 'audio_size', 'playback_url']);

        $upload = $response->json();

        $this->assertSame('talk.mp3', $upload['audio_original_name']);
        $this->assertSame('audio/mpeg', $upload['audio_mime']);
        $this->assertSame(11, $upload['audio_size']);
        Storage::disk(config('catalog.audio_disk'))->assertExists($upload['audio_path']);
        $this->assertSame(
            'hello world',
            Storage::disk(config('catalog.audio_disk'))->get($upload['audio_path']),
        );
        $this->get($upload['playback_url'])->assertOk();
    }

    public function test_tus_upload_rejects_unsupported_file_types(): void
    {
        $this->actingAs($this->admin);

        $this->call('POST', route('admin.audios.tus.create'), [], [], [], [
            'HTTP_TUS_RESUMABLE' => '1.0.0',
            'HTTP_UPLOAD_LENGTH' => '10',
            'HTTP_UPLOAD_METADATA' => $this->encodeMetadata([
                'filename' => 'malware.exe',
                'filetype' => 'application/octet-stream',
            ]),
        ])->assertStatus(415);
    }

    public function test_tus_upload_rejects_an_invalid_offset(): void
    {
        $location = $this->createUpload('talk.mp3', 'audio/mpeg', 11);

        $this->sendPatch($location, 3, 'hello')
            ->assertStatus(409);
    }

    public function test_tus_upload_cannot_complete_before_all_chunks_arrive(): void
    {
        $location = $this->createUpload('talk.mp3', 'audio/mpeg', 11);
        $this->sendPatch($location, 0, 'hello');

        $id = basename(parse_url($location, PHP_URL_PATH));

        $this->actingAs($this->admin)
            ->postJson(route('admin.audios.tus.complete', ['upload' => $id]))
            ->assertStatus(409);
    }

    public function test_tus_upload_can_be_terminated(): void
    {
        $location = $this->createUpload('talk.mp3', 'audio/mpeg', 11);

        $this->call('DELETE', $location, [], [], [], [
            'HTTP_TUS_RESUMABLE' => '1.0.0',
        ])->assertStatus(204);

        $this->sendHead($location)->assertNotFound();
    }

    public function test_tus_endpoint_requires_an_authenticated_admin(): void
    {
        $this->withHeaders([
            'Tus-Resumable' => '1.0.0',
            'Upload-Length' => '11',
        ])->post(route('admin.audios.tus.create'))->assertRedirect(route('login'));
    }

    private function createUpload(string $filename, string $mime, int $length): string
    {
        $this->actingAs($this->admin);

        $response = $this->call('POST', route('admin.audios.tus.create'), [], [], [], [
            'HTTP_TUS_RESUMABLE' => '1.0.0',
            'HTTP_UPLOAD_LENGTH' => (string) $length,
            'HTTP_UPLOAD_METADATA' => $this->encodeMetadata([
                'filename' => $filename,
                'filetype' => $mime,
            ]),
        ]);

        $response->assertStatus(201)->assertHeader('Tus-Resumable', '1.0.0');

        $location = $response->headers->get('Location');
        $this->assertNotNull($location);
        $this->assertStringStartsWith('/admin/audios/tus/', $location);

        return $location;
    }

    private function sendHead(string $location)
    {
        return $this->call('HEAD', $location, [], [], [], [
            'HTTP_TUS_RESUMABLE' => '1.0.0',
        ]);
    }

    private function sendPatch(string $location, int $offset, string $content)
    {
        return $this->call('PATCH', $location, [], [], [], [
            'HTTP_TUS_RESUMABLE' => '1.0.0',
            'HTTP_UPLOAD_OFFSET' => (string) $offset,
            'CONTENT_TYPE' => 'application/offset+octet-stream',
            'CONTENT_LENGTH' => (string) strlen($content),
        ], $content);
    }

    /**
     * @param  array<string, string>  $metadata
     */
    private function encodeMetadata(array $metadata): string
    {
        return collect($metadata)
            ->map(fn (string $value, string $key): string => $key.' '.base64_encode($value))
            ->implode(',');
    }
}
