# aaPanel Deployment Plan: Backend and Static Media

This plan deploys the Buddha Audio Laravel backend and its persistent media files to one aaPanel server. It includes the REST API, the Laravel/Vue admin dashboard, and audio, cover, and teacher-photo storage. It does not deploy the Flutter mobile apps.

## 1. Deployment layout

Use one HTTPS hostname for both the API and admin dashboard so Laravel can generate correct signed playback URLs. Replace the example domain and paths below with the production values.

| Component | Location / value |
| --- | --- |
| aaPanel PHP website document root | `/www/wwwroot/buddha-audio/backend/public` |
| Laravel project | `/www/wwwroot/buddha-audio/backend` |
| Persistent uploads | `/www/wwwroot/buddha-audio-shared/static` |
| Public hostname | `https://api.example.com` |
| Admin dashboard | `https://api.example.com/admin` |
| API base | `https://api.example.com/api/v1` |

Keep `static/` outside the web document root and outside replaceable release directories. The application accesses it through the configured Laravel `static` filesystem disk. Audio stays private; signed Laravel routes authorize playback. Nginx can send authorized audio bytes directly from disk with the optional internal media location in section 5.

## 2. aaPanel server preparation

1. Point the production DNS record at the server and allow inbound HTTP/HTTPS traffic.
2. In aaPanel, install Nginx, PHP 8.4, MySQL or MariaDB, and Redis. The project targets PHP 8.3+ and is developed on PHP 8.4; use PHP 8.4 for both PHP-FPM and CLI.
3. Enable the PHP extensions required by Laravel and the project, including `curl`, `fileinfo`, `mbstring`, `openssl`, `pdo_mysql`, `tokenizer`, `xml`, and `ctype`. Enable the PHP Redis extension when using the configured `phpredis` client.
4. Install Composer 2 and Node.js/npm 20.19+ or 22.12+ on the build host. Node/npm are only needed on the server if assets will be built there; this matches the Vite version in the project lockfile.
5. Create an empty production database and a dedicated database user in aaPanel. Grant that user access only to this database. Record its name, username, password, and host for `.env`.
6. Create an aaPanel PHP website for `api.example.com`. Set its document root to `/www/wwwroot/buddha-audio/backend/public`, select PHP 8.4, and issue/enable an HTTPS certificate. aaPanel supports a PHP website with a configurable document root and per-site PHP version; see its [PHP Project documentation](https://www.aapanel.com/docs/Function/php.html).

## 3. Prepare and upload the release

Deploy from the project's Git repository or upload a release archive. Keep `.env`, `storage/`, and the persistent media directory when replacing application code.

```bash
cd /www/wwwroot/buddha-audio/backend
composer install --no-dev --prefer-dist --optimize-autoloader
npm ci
npm run build
```

The Vite build creates `public/build`, which serves the admin dashboard's CSS and JavaScript. If building on a separate machine, run the same commands there and include `public/build` in the release. The production server does not need Node.js when the built assets are included.

Create the persistent media directories before the first request:

```bash
mkdir -p /www/wwwroot/buddha-audio-shared/static/audio/tus
mkdir -p /www/wwwroot/buddha-audio-shared/static/audio/pending
mkdir -p /www/wwwroot/buddha-audio-shared/static/covers
mkdir -p /www/wwwroot/buddha-audio-shared/static/teachers
```

Set ownership so the PHP-FPM site user can write to Laravel's `storage`, `bootstrap/cache`, and the persistent `static` tree. Nginx must be able to read the static files for the optional X-Accel delivery. Use the site's actual aaPanel user/group and grant only the required access; do not make these paths world-writable.

## 4. Configure production environment

Create `backend/.env` on the server. Do not commit it or put secrets in a public directory. Set at least the following values:

```dotenv
APP_NAME="Buddha Audio"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.example.com
APP_KEY=

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=<production_database>
DB_USERNAME=<production_database_user>
DB_PASSWORD=<strong_database_password>

SESSION_DRIVER=database
SESSION_SECURE_COOKIE=true
SESSION_DOMAIN=api.example.com
QUEUE_CONNECTION=database

CACHE_STORE=redis
REDIS_CLIENT=phpredis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=<redis_password_or_null>
REDIS_PORT=6379
CATALOG_CACHE_STORE=redis

FILESYSTEM_DISK=local
CATALOG_AUDIO_DISK=static
CATALOG_COVER_DISK=static
STATIC_FILES_PATH=/www/wwwroot/buddha-audio-shared/static
CATALOG_AUDIO_MAX_BYTES=524288000
CATALOG_PLAYBACK_URL_TTL=30

CATALOG_NGINX_MEDIA_ENABLED=true
CATALOG_NGINX_MEDIA_INTERNAL_PREFIX=/_protected_media

LOG_LEVEL=warning
```

Generate `APP_KEY` once during initial setup using the command in section 6; preserve it across all future releases and backups. Set `TRUSTED_PROXIES` to the trusted proxy or load-balancer IPs if the site sits behind one; do not leave `*` unless every request reaching Laravel comes through a trusted proxy. Configure a real mail transport before relying on password-reset email. If Redis is unavailable, use Laravel's `file` cache and set `CATALOG_CACHE_STORE=file` instead.

### Initial admin account

Do not run the full `DatabaseSeeder` in production: it also creates sample catalog records. The current `AdminUserSeeder` contains the known credentials `admin@example.com` / `password`. Before provisioning the first production account, change the seeder to use a unique production email and a strong one-time password (or use a controlled, secure account-provisioning method). Run only the reviewed admin seeder, then sign in and change the password immediately. Do not leave the repository's default credentials active.

## 5. Configure the aaPanel Nginx site

Keep aaPanel's generated PHP-FPM handler and SSL directives. Set the site's root to the Laravel `public/` directory, use Laravel's front-controller rewrite, and add an upload-body limit of at least 10 MB. The admin uploader sends resumable Tus requests in 5 MB chunks; the total upload size is controlled separately by `CATALOG_AUDIO_MAX_BYTES`.

Add or adapt these directives in the site configuration using aaPanel's site `Conf` editor. Do not replace the generated PHP-FPM configuration wholesale:

```nginx
root /www/wwwroot/buddha-audio/backend/public;
index index.php;
client_max_body_size 10m;

location / {
    try_files $uri $uri/ /index.php?$query_string;
}

# Only Laravel-authorized responses can use this internal location.
location ^~ /_protected_media/ {
    internal;
    alias /www/wwwroot/buddha-audio-shared/static/;
    sendfile on;
}
```

The trailing slash on the `alias` is required. The path must match `STATIC_FILES_PATH`. Keep aaPanel's existing PHP-FPM location and SSL configuration. Validate and reload Nginx using aaPanel after editing the site configuration. See the project's [Nginx media delivery guide](nginx-media-proxy-deployment.md) for the X-Accel behavior, permissions, and troubleshooting details.

If X-Accel delivery is not enabled, set `CATALOG_NGINX_MEDIA_ENABLED=false` (or omit it). Laravel then serves audio through PHP. Do not enable the flag unless the internal Nginx location maps to the same local media directory.

## 6. First deployment and cutover

From the backend directory, run the production setup commands after `.env` and permissions are in place:

```bash
cd /www/wwwroot/buddha-audio/backend
php artisan key:generate --force
php artisan migrate --force
php artisan db:seed --class=AdminUserSeeder --force
php artisan optimize
```

Run the seeder command only after reviewing and securing `AdminUserSeeder` as described above. Do not regenerate `APP_KEY` on later deployments. `migrate --force` applies schema changes without deleting existing data. Ensure the PHP-FPM user can write to `storage/` and `bootstrap/cache/` before warming Laravel's caches.

If migrating an existing installation, take a database backup first, copy existing audio, covers, and teacher photos into the persistent static path while preserving their subdirectories, then verify counts and permissions before pointing production traffic at the new release. Keep the old database and files until cutover checks pass.

## 7. Smoke checks

After DNS, HTTPS, Nginx, and PHP-FPM are active:

1. Open `https://api.example.com/up`; expect a successful health response.
2. Request `https://api.example.com/api/v1/home`; expect JSON, not an HTML error page.
3. Open `/admin`, sign in with the provisioned account, change its password, and confirm the dashboard and bundled assets load correctly.
4. Upload a small audio file and a cover image from the admin dashboard. Confirm the Tus upload completes and files appear under the persistent `static/` tree.
5. Publish a test audio item and request its signed playback URL. Confirm the audio plays and supports seeking. Confirm an expired or modified signed URL is rejected.
6. Open an API cover-image URL and confirm the image is returned. Request `/_protected_media/audio/<filename>` directly and confirm Nginx denies it (normally `404`) because the location is `internal`.
7. Review aaPanel Nginx/PHP logs and `backend/storage/logs/laravel.log` for permission, database, URL-signature, or upload errors.

## 8. Backups, updates, and rollback

- Schedule separate backups for the MySQL database and `/www/wwwroot/buddha-audio-shared/static`. Test restoring both; a code-only backup is insufficient.
- For each update, back up the database and media, deploy the new code, install production Composer dependencies, build or upload `public/build`, run `php artisan migrate --force`, and refresh Laravel caches with `php artisan optimize`.
- Keep `.env`, `APP_KEY`, database data, and the static directory persistent when rolling back code. If a migration is not backward-compatible, restore the matching pre-deployment database backup before restoring the old release.
- Monitor disk space, failed uploads, PHP-FPM/Nginx errors, Laravel logs, and backup completion. The database queue is configured, but this application currently has no required always-on worker for its normal API/admin flow; add a supervised worker if background jobs are introduced.

## aaPanel reference

- [aaPanel PHP Project documentation](https://www.aapanel.com/docs/Function/php.html)
- [aaPanel website deployment overview](https://www.aapanel.com/docs/guide/deploywebsite.html)
- [Project Nginx media delivery guide](nginx-media-proxy-deployment.md)
