# TaskFlow

TaskFlow is a Flutter application for organizing projects, tasks, and team productivity workflows.

## Tech Stack

- Flutter
- Dart
- Material Design 3

## Project Structure

```
lib/
  core/        # App-wide constants, routing, theme, utils, and error handling
  features/    # Domain features (auth, dashboard, projects, settings, tasks)
  l10n/        # Localization files and generated localization classes
  shared/      # Shared reusable widgets
```

## Prerequisites

- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)
- Android Studio or VS Code with Flutter extensions

## Getting Started

1. Install dependencies:

	```bash
	flutter pub get
	```

2. Run the app:

	```bash
	flutter run
	```

3. Run tests:

	```bash
	flutter test
	```

## Localization

This project includes English and French localization resources in `lib/l10n/`.

## Supported Platforms

- Android
- iOS
- Web
- Linux
- macOS
- Windows
