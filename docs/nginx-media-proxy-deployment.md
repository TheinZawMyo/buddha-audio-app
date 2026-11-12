# Mobile Media Delivery Through Nginx

This guide describes how the mobile app can request covers, teacher photos, and audio through the Laravel API while Nginx sends the file bytes directly from disk with `X-Accel-Redirect`. Nginx and the media files must be on the same host or on a shared filesystem that Nginx can read.

## Current project setup

- Cover and teacher photo URLs use `/api/v1/media/{directory}/{filename}`.
- Audio URLs use the temporary signed route `/api/v1/audios/{slug}/stream`. Laravel checks the signature and file availability, then currently sends the file response through PHP.
- By default, local media is stored in `static/audio`, `static/covers`, and `static/teachers` at the repository root. Set `STATIC_FILES_PATH` to change this root.
- Flutter uses the API base URL's origin for image and audio requests. Nginx can sit in front of Laravel without changing the route paths or signed query strings.

## Local setup

1. Run Nginx locally and forward API requests to the Laravel development server. You can use `php artisan serve` as the upstream. Make Nginx listen on an interface that the mobile simulator or device can reach.
2. Add an `internal` Nginx location for `/_protected_media/` and map it to the local `static/` directory with `alias`. The `internal` directive prevents clients from requesting media files directly through that path.
3. Set `CATALOG_NGINX_MEDIA_ENABLED=true` and `CATALOG_NGINX_MEDIA_INTERNAL_PREFIX=/_protected_media` in `.env`. After Laravel verifies the signed audio URL, validates the media route's directory and filename, and confirms the file exists, it returns an `X-Accel-Redirect` header such as `/_protected_media/audio/<filename>`. PHP sends the response headers but not the file body; Nginx sends the file. For a non-local filesystem disk, X-Accel is not used and the existing response path remains in effect.
4. Set `STATIC_FILES_PATH` in `.env` to an absolute path that Nginx can read. Confirm `CATALOG_AUDIO_DISK=static` and `CATALOG_COVER_DISK=static`. The Nginx worker user needs permission to traverse the directory tree and read the files.
5. Set `APP_URL` to the same Nginx origin that the app uses so Laravel generates valid URLs and signed playback URLs. Run Flutter with `--dart-define=API_BASE_URL=http://<host-or-LAN-IP>:<nginx-port>/api/v1`. From the Android emulator, use `10.0.2.2` to reach the host. From a physical device, use the computer's LAN IP instead of `localhost`. If the scheme, host, or port seen by the app differs from `APP_URL`, signed audio URLs may be invalid.
6. If Laravel configuration is cached, run `php artisan config:clear` after changing `.env`. Validate the Nginx configuration with `nginx -t`, then reload Nginx.

Example local Nginx `server` block (change the paths and port for your environment):

```nginx
server {
    listen 8080;
    server_name localhost;

    # Clients cannot request this location directly.
    location ^~ /_protected_media/ {
        internal;
        alias /absolute/path/to/buddha-audio-project/static/;
        sendfile on;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Keep the trailing slash on the `alias` path. For example, `X-Accel-Redirect: /_protected_media/audio/example.mp3` maps to `static/audio/example.mp3`. Do not add `proxy_ignore_headers X-Accel-Redirect`.

## Production Nginx

Configure Nginx with Laravel's `public/` directory as the document root and PHP-FPM as the upstream, then add the media location shown below. Replace the PHP-FPM socket, document root, and domain with the values for your server.

```nginx
server {
    listen 443 ssl http2;
    server_name api.example.com;

    root /srv/buddha-audio/backend/public;
    index index.php;

    # Keep static/ outside the public web root. Nginx serves it only through this internal redirect.
    location ^~ /_protected_media/ {
        internal;
        alias /srv/buddha-audio/static/;
        sendfile on;
    }

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
    }
}
```

The example omits TLS certificate directives. Nginx and PHP-FPM must see the same `static/` path. The PHP upload user must be able to write files, and the Nginx worker user must be able to read them and traverse their parent directories. A local disk on each application server is not sufficient for a multi-server deployment; use shared storage or an object storage/CDN setup that Nginx can access. `X-Accel-Redirect` does not make an S3 object available through a local Nginx `alias`.

## Laravel and environment settings

- Keep file existence and path validation in `MediaService::stream()` and `serveMedia()`. When `CATALOG_NGINX_MEDIA_ENABLED=true` and the configured disk uses the local filesystem, Laravel returns an `X-Accel-Redirect` header instead of sending the file with `response()->file()`. When the flag is disabled, the current PHP file response is used.
- Keep the `signed` middleware on the audio stream route. Nginx must serve the file only after Laravel has authorized the request.
- Do not build the internal URI directly from a client-provided path. Retain the existing directory allow-list and filename validation.
- Set `APP_URL=https://api.example.com` to the public API origin. Restrict `TRUSTED_PROXIES` to the IP addresses of Nginx or the load balancer, and confirm Laravel trusts the forwarded HTTPS header. Set `APP_DEBUG=false`.
- Set `STATIC_FILES_PATH=/srv/buddha-audio/static`, `CATALOG_AUDIO_DISK=static`, `CATALOG_COVER_DISK=static`, `CATALOG_NGINX_MEDIA_ENABLED=true`, and `CATALOG_NGINX_MEDIA_INTERNAL_PREFIX=/_protected_media` (or use your chosen shared path). Laravel's disk root and the Nginx `alias` must point to the same directory.
- Back up the database and media separately. Keep media in a persistent shared path so it is not lost when a deployment switches release directories or symlinks.

## Deployment steps

1. On staging, check the `X-Accel-Redirect` code, Nginx internal alias, PHP-FPM configuration, and media path. Confirm that X-Accel is used only for the `static` local disk and that other storage drivers continue to use the existing response path.
2. Copy or migrate existing media files to the persistent directory and verify PHP/Nginx permissions. Back up the original files and database first.
3. Set the production origin, disk, and proxy values in `.env`, then deploy the release. Reload Nginx only after `nginx -t` succeeds. Rebuild Laravel's config, route, and view caches according to your deployment process.
4. Set the mobile build's `API_BASE_URL` to `https://api.example.com/api/v1`. Confirm that URLs returned by the API use the same host.
5. If a problem occurs, temporarily disable the Nginx internal location and `X-Accel-Redirect` header, then roll back the code/configuration to the previous Laravel response delivery. Do not delete the media path or database during rollback.

## Post-deployment checks

- Open a cover image and a teacher photo from the public API. Confirm that each returns the expected image bytes and `Content-Type`.
- Open a signed audio stream URL in the app and check playback, seeking, and downloads. An expired or modified signature should return `403` and must not expose the file.
- Request `/_protected_media/audio/<existing-file>` directly from a browser or `curl`. Nginx should return `404`.
- Confirm that a missing media file returns `404`. Check `Content-Length`, `Content-Range`/seeking, and the mobile app's offline cache after a download.
- Check Nginx access/error logs and PHP/Laravel logs for permission errors, upstream errors, or storage misses.

## Common issues

- **404:** Compare the Nginx `alias`, Laravel `STATIC_FILES_PATH`, and actual file path. Confirm the `alias` has a trailing slash.
- **403 or permission denied:** Confirm that the Nginx worker user can traverse each parent directory and read the file.
- **Invalid signed URL:** Check that `APP_URL`, `API_BASE_URL`, and the forwarded scheme/host/port match. Review Nginx proxy headers and Laravel trusted proxy settings.
- **Nginx returns a blank response instead of the file:** Confirm that the `X-Accel-Redirect` URI matches the `internal` location, `proxy_ignore_headers` is not configured, and the Laravel response includes the expected header.
- **S3/CDN disk:** A local `alias` cannot read an object storage path, so do not use `X-Accel-Redirect` for that disk. Use a signed object URL/CDN or a separate origin proxy.
- **Upload failure:** This change does not alter the upload flow. Keep `client_max_body_size` and PHP/Nginx request limits large enough for the existing 5 MB Tus chunks.
