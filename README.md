# Keihatsu Mobile 📖

A modern, offline-first manga and light novel reader built with **Flutter**. Keihatsu provides a seamless reading experience with extension-based content discovery, deep customization, and cloud synchronization.

## 🌟 Key Features

- **Extension System**: Discover content from various sources via a modular extension architecture.
- **Offline-First Library**: Fast, local database management using **Isar DB** for a responsive experience even without internet.
- **Persistent Themes**: Fully customizable UI with persistent brand colors, light/dark modes, and "Pure Black" OLED support.
- **Advanced Reader**: High-performance reader with chapter bookmarking, history tracking, and smooth navigation.
- **Download Manager**: Save chapters locally for offline reading with background download support.
- **Global Search**: Search for manga across all enabled extensions simultaneously.
- **Community**: Real-time nested comments and interactive user profiles.
- **Smart Sync**: Seamlessly sync your library, history, and preferences with the Keihatsu API.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Database**: [Isar](https://isar.dev/) (NoSQL, high performance)
- **Local Storage**: [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Networking**: [http](https://pub.dev/packages/http) & [Dio](https://pub.dev/packages/dio)
- **Icons & Fonts**: [Phosphor Icons](https://pub.dev/packages/phosphor_flutter) & [Google Fonts](https://pub.dev/packages/google_fonts)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio / VS Code with Flutter extension
- An active instance of the [Keihatsu API](https://github.com/DanielsFega/keihatsu-api)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Generate local database schemas:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Configure API Endpoint:
    - Open `lib/services/api_constants.dart`
    - Update `baseUrl` to point to your running backend API.

5. Run the app:
   ```bash
   flutter run
   ```

## 📂 Project Structure

```text
lib/
├── components/     # Reusable UI Widgets
├── models/         # Data Models & Isar Schemas
├── providers/      # State Management (Theme, Auth, Library)
├── screens/        # Feature Pages (Home, Reader, Settings)
├── services/       # API Clients & Repository Logic
└── theme_provider.dart # Global UI Styling & Persistence
```

## 🛡️ License

MIT License. See [LICENSE](LICENSE) for details.
