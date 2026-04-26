# TaskFlow

TaskFlow is a Flutter productivity app for managing projects and tasks with a clean, feature-based structure. The app supports local persistence, notifications, and multilingual UI.

## Table Of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Tech Stack](#tech-stack)
4. [Architecture](#architecture)
5. [Project Structure](#project-structure)
6. [Getting Started](#getting-started)
7. [Development Workflow](#development-workflow)
8. [Localization](#localization)
9. [Storage](#storage)
10. [Notifications](#notifications)
11. [Supported Platforms](#supported-platforms)
12. [Troubleshooting](#troubleshooting)

## Overview

TaskFlow helps users:

- Create and manage projects.
- Create, update, filter, and track tasks.
- Organize work using status and priority.
- Work in English and French.
- Receive local reminders and task-related notifications.

## Features

- Authentication flow (login/register screens).
- Project management (create, edit, delete).
- Task management with status progression and due dates.
- Dashboard screens for productivity overview.
- App settings (including locale/theme preferences).
- Local persistence with Hive.
- Local notifications for due tasks and completion events.

## Tech Stack

- Flutter (Material 3)
- Dart
- Riverpod (`flutter_riverpod`) for state management and dependency injection
- `go_router` for navigation
- Hive (`hive`, `hive_flutter`) for local database storage
- `shared_preferences` for lightweight app preferences
- `flutter_local_notifications` + `timezone` for reminders
- `intl` + Flutter l10n for localization
- `fl_chart` for charts/visualizations

## Architecture

The app uses a feature-first layered architecture inspired by Clean Architecture:

- `presentation`: screens, providers, state notifiers
- `domain`: entities and repository contracts
- `data`: repository implementations and data models

This is a pragmatic setup rather than strict Clean Architecture:

- There is no dedicated use-case layer yet.
- Some flows use data models directly through layers for simplicity.

## Project Structure

```text
lib/
	core/
		constants/     # Keys, box names, shared constants
		errors/        # App-level exception types
		router/        # Navigation and route guards/notifier
		theme/         # Light/dark theme definitions
		utils/         # Helpers, providers, notifications
	features/
		auth/
			data/
			domain/
			presentation/
		dashboard/
			presentation/
		projects/
			data/
			domain/
			presentation/
		settings/
			presentation/
		tasks/
			data/
			domain/
			presentation/
	l10n/            # ARB files and generated localization classes
	shared/
		widgets/       # Reusable UI components
	main.dart        # App bootstrap and global initialization
```

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Dart SDK (bundled with Flutter)
- Android Studio or VS Code with Flutter/Dart extensions

Check your installation:

```bash
flutter doctor
```

### Install Dependencies

```bash
flutter pub get
```

### Run The App

```bash
flutter run
```

Run on a specific device:

```bash
flutter devices
flutter run -d <device_id>
```

### Run Tests

```bash
flutter test
```

## Development Workflow

### Generate Hive Adapters

When updating `@HiveType` models, regenerate code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Static Analysis

```bash
flutter analyze
```

### Formatting

```bash
dart format lib test
```

## Localization

Localization is enabled through Flutter gen-l10n.

- Source files: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`
- Generated classes: `lib/l10n/app_localizations*.dart`
- Supported locales: English (`en`) and French (`fr`)

After editing ARB files, run:

```bash
flutter gen-l10n
```

## Storage

TaskFlow persists data locally using Hive.

- Boxes are initialized at app startup in `main.dart`.
- Current entities include users, projects, and tasks.
- Box names are centralized in `lib/core/constants/hive_boxes.dart`.

Preferences such as app settings are stored using `shared_preferences`.

## Notifications

Local notifications are initialized during app startup.

- Notification helper: `lib/core/utils/notification_service.dart`
- Task flows can trigger reminders for due dates and completion updates.

Platform-specific notification permissions/configuration may be required on iOS/Android depending on OS version.

## Supported Platforms

- Android
- iOS
- Web
- Linux
- macOS
- Windows

## Troubleshooting

### Build runner conflicts

Use:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Localization not updating

Use:

```bash
flutter gen-l10n
```

### Packages out of sync

Use:

```bash
flutter clean
flutter pub get
```
