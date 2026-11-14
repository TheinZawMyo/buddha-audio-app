# DhammaWave

A new Flutter project.

## API configuration

Copy `.env.example.json` to `.env.json`, then set `API_BASE_URL` and the API key generated from the Laravel admin panel. `.env.json` is ignored by Git.

Run and build with the config file from the `app` directory:

```sh
flutter run --dart-define-from-file=.env.json
flutter build apk --release --dart-define-from-file=.env.json
```

Flutter compiles `API_KEY` into the app binary. Treat it as a revocable app identifier with a server-side rate limit, not as a secret or user authentication credential.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
