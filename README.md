# Buddha Audio

A Dhamma audio catalog for listeners and publishers. The project contains a
Flutter listener app, a versioned Laravel REST API, and a Vue/Inertia admin
dashboard for managing teachers, categories, audio types, and audio recordings.

- **Mobile:** Flutter (Riverpod, Dio, just_audio, audio_service)
- **Backend:** Laravel 13 + PHP 8.4, repository/service architecture
- **Admin UI:** Vue 3 + Inertia.js + Tailwind CSS (no Blade templates)
- **Database:** SQLite for local development; MySQL/PostgreSQL supported in production
- **Storage:** private local disk for audio, public disk for cover images (S3-compatible disks supported)

See [`ARCHITECTURE.md`](ARCHITECTURE.md) for the full domain model, API outline,
and deployment direction (written in Burmese).

## Repository layout

```
.
├── app/                 # Flutter listener app
├── backend/             # Laravel API + admin dashboard
│   ├── app/
│   │   ├── Http/Controllers/Api/V1/   # Public JSON API
│   │   ├── Http/Controllers/Admin/    # Inertia admin controllers
│   │   ├── Http/Resources/Api/V1/     # API resources
│   │   ├── Models/                    # Eloquent models (UUID + soft deletes)
│   │   ├── Repositories/              # Contracts + Eloquent implementations
│   │   └── Services/                  # Catalog, media, slug, audit, dashboard logic
│   ├── database/migrations/
│   ├── database/seeders/
│   ├── resources/js/Pages/Admin/      # Inertia/Vue admin pages
│   ├── routes/api.php
│   └── routes/web.php
└── ARCHITECTURE.md
```

## Features

### Public API

- Home sections with featured audio, latest audio, teachers, categories, and types.
- Published-audio listing with search and filters for teacher, category, and type.
- Cursor pagination and stable `data` + `meta` response envelope.
- Audio detail by slug.
- Short-lived signed stream URLs for privately stored files; external playback
  URLs are returned as-is.
- Only `published` audio and active taxonomy records are exposed. Draft,
  archived, and soft-deleted records return `404`.

### Admin dashboard

- Session-based login (registration is intentionally disabled).
- Dashboard with status counts and recent activity.
- CRUD for teachers, categories, and audio types.
- Audio lifecycle: create draft, upload audio/cover, edit metadata, publish, archive,
  and soft delete.
- Publish validation requires a playable asset and a positive duration.
- Audit log for create, update, publish, archive, and delete actions.
- Deactivated users are logged out automatically.

### Flutter app

- Live catalog data from the versioned Laravel API.
- Platform-aware API URL with a build-time override.
- Browse, search, audio details, mini/full player, and background audio.
- A single **Saved** navigation page with Favorites and Downloads tabs.
- Playback caches audio in app-private storage while streaming. Saved tracks can
  be played offline; the detail page also offers a full download action.
- Downloaded audio stays in the app's private files directory and is managed in
  the Downloads tab, rather than being added to the device's public music folder.

## Requirements

- PHP 8.3+ (developed on 8.4)
- Composer 2
- Node.js 20+ and npm
- SQLite (default) or MySQL/PostgreSQL
- Flutter with Dart 3.13.2 or newer (for the mobile app)

## Backend setup

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
touch database/database.sqlite
php artisan migrate --seed
php artisan storage:link
npm install
npm run build
php artisan serve
```

Then open:

- Admin dashboard: <http://localhost:8000/admin>
- Public API base: <http://localhost:8000/api/v1>

The seeder creates a sample catalog and an admin account:

```text
Email:    admin@example.com
Password: password
```

Change this password before deploying. If you only want the schema, run
`php artisan migrate` without `--seed`.

For frontend development, run Vite in a second terminal:

```bash
cd backend
npm run dev
```

`composer run dev` is also available and starts the Laravel development process
configured in `composer.json`.

## Public API

All routes are prefixed with `/api/v1`. Responses use JSON and do not require
authentication.

| Method | Endpoint | Description |
| --- | --- | --- |
| `GET` | `/home` | Featured/latest audio plus active teachers, categories, and types |
| `GET` | `/audios` | Published audio list; supports `query`, `teacher`, `category`, `type`, `cursor`, and `limit` (max 50) |
| `GET` | `/audios/{slug}` | Published audio detail |
| `POST` | `/audios/{slug}/playback-url` | Returns a playback URL for a published audio |
| `GET` | `/teachers` | Active teachers |
| `GET` | `/teachers/{slug}` | Active teacher detail |
| `GET` | `/categories` | Active categories |
| `GET` | `/audio-types` | Active audio types |
| `GET` | `/audios/{slug}/stream` | Signed stream endpoint; called through a generated playback URL |

List response:

```json
{
  "data": [
    {
      "id": "uuid",
      "slug": "ratanasutta",
      "title": "ရတနာသုတ်",
      "description": "...",
      "teacher": { "id": "uuid", "slug": "ashin-thuwanna", "name": "အရှင်သုဝဏ္ဏ" },
      "type": { "id": "uuid", "slug": "chanting", "name": "ရွတ်ဖတ်" },
      "categories": [],
      "duration_seconds": 540,
      "language": "my",
      "cover_image_url": "https://...",
      "playback_url": "https://...",
      "published_at": "2026-10-20T12:00:00+00:00"
    }
  ],
  "meta": {
    "pagination": {
      "next_cursor": null,
      "has_more": false,
      "total": 12
    }
  }
}
```

Example requests:

```bash
curl http://localhost:8000/api/v1/home
curl "http://localhost:8000/api/v1/audios?category=paritta&limit=10"
curl http://localhost:8000/api/v1/audios/ratanasutta
curl -X POST http://localhost:8000/api/v1/audios/ratanasutta/playback-url
```

## Admin routes

| Path | Purpose |
| --- | --- |
| `/login` | Admin/editor login |
| `/admin` | Dashboard |
| `/admin/teachers` | Teacher management |
| `/admin/categories` | Category management |
| `/admin/audio-types` | Audio type management |
| `/admin/audios` | Audio list and lifecycle actions |
| `/admin/audit-logs` | Audit history |

All `/admin` routes require an authenticated, active user. The `role` column
currently stores `admin` or `editor`; role-specific authorization is reserved
for a later iteration.

## Configuration

Catalog behavior is configured in `backend/config/catalog.php` and can be
overridden with environment variables:

| Variable | Default | Purpose |
| --- | --- | --- |
| `CATALOG_AUDIO_DISK` | `local` | Disk for private audio uploads |
| `CATALOG_COVER_DISK` | `public` | Disk for public cover images |
| `CATALOG_PLAYBACK_URL_TTL` | `30` | Signed playback URL lifetime in minutes |
| `CATALOG_PER_PAGE` | `15` | Admin pagination size |
| `CATALOG_HOME_FEATURED_LIMIT` | `4` | Home featured audio limit |
| `CATALOG_HOME_LATEST_LIMIT` | `8` | Home latest audio limit |

Database, cache, session, and filesystem settings use the standard Laravel
`.env` variables. For production, switch `DB_CONNECTION` to MySQL/PostgreSQL,
configure a persistent queue/cache, and point the storage disks at private
S3-compatible object storage (or keep the local disk with durable volumes).

## Testing and code style

```bash
cd backend
php artisan test --compact
vendor/bin/pint
```

The feature suite covers the public API, admin access control, catalog CRUD,
validation, audit logging, publish/archive rules, uploads, signed streaming,
and soft deletion.

## Flutter app

```bash
cd app
flutter pub get
flutter run
```

The API URL is selected automatically:

- Android emulator: `http://10.0.2.2:8000/api/v1`
- iOS Simulator, macOS, and desktop: `http://localhost:8000/api/v1`

For a physical device or a deployed API, override it at build time:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000/api/v1
```

When testing from a physical device, start Laravel with
`php artisan serve --host=0.0.0.0` so it accepts connections from the LAN.
Use HTTPS in production.

```bash
cd app
flutter test
flutter analyze
```

## Audio storage and playback

- Uploaded audio is stored on the private `local` disk (`storage/app/private`)
  and never exposed directly.
- Public clients receive a temporary signed URL generated by `Audio::playback_url`.
- If `external_playback_url` is set, that URL is returned instead, which allows
  CDN-hosted audio.
- Publishing is blocked until the record has either an uploaded file or an
  external URL and a duration of at least one second.
- Draft and archived records are excluded from all public endpoints.
- Archived content keeps its storage file until it is explicitly deleted.

The Flutter app caches tracks in its private documents directory as they are
streamed. Users can also download a complete track from its detail page. Both
automatically cached and explicitly downloaded tracks appear under **Saved →
Downloads**, where they can be played without a network connection or removed
from the device. Audio files are not exported to the public music/download
folders; clearing the app's data or uninstalling it removes the local copies.

## Production notes

- Set `APP_ENV=production`, `APP_DEBUG=false`, and a strong `APP_KEY`.
- Change the seeded admin password and disable unused accounts.
- Serve the app over HTTPS and configure trusted proxies/hosts.
- Run migrations during deployment and cache config/routes/views as appropriate.
- Use a queue worker for future media-processing jobs.
- Back up the database and object storage; retain deleted media according to your
  retention policy.
- Keep secrets in environment variables or a secret manager, never in the repo.
