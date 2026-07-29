# 🌸 BabyBloom

BabyBloom is a modern Flutter app designed to support parents and caregivers in managing a baby’s daily needs with ease. It combines health, vaccination, reminder, and family-support features in one simple and friendly experience.

## ✨ What BabyBloom offers

- 👶 Baby profile management
- 💉 Vaccine tracking and status updates
- 📅 Calendar view with reminders
- 🔔 Local notifications for important tasks
- 📈 Growth tracking support
- 🏥 MOH clinic and health guidance access
- 🚨 Emergency contacts for quick support
- ☁️ Backup and restore support
- 🌙 Light and dark mode
- 🌍 Multi-language support

## 🧩 App highlights

BabyBloom helps parents stay organized through:

- vaccination schedules
- appointment reminders
- baby growth records
- emergency contact access
- health information and support resources

The app is built to feel calm, modern, and useful for everyday parenting.

## 🛠️ Tech stack

- Flutter
- Dart
- Firebase Auth
- Cloud Firestore
- SQLite for local storage
- Flutter Local Notifications
- Material 3 UI

## 📁 Project structure

```text
lib/
  data/            # local and remote data helpers
  database/        # SQLite database layer
  l10n/            # localization files
  models/          # app data models
  screens/         # app screens and pages
  theme/           # app theme and colors
  utils/           # utility classes and helpers
  widgets/         # reusable UI components
```

## ✅ Requirements

Before running the app, make sure you have:

- Flutter SDK installed
- An emulator or physical device connected
- Firebase configured for your environment

## ▶️ Getting started

1. Clone the repository
   ```bash
   git clone <your-repo-url>
   cd ammata_help_lk-main
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Configure Firebase
   - Make sure your Firebase project is set up
   - Add the required Firebase configuration files for Android/iOS/Web
   - If needed, generate options with FlutterFire

4. Run the app
   ```bash
   flutter run
   ```

## 🔧 Useful commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## 🌐 Localization

The app includes localization support and is prepared for multiple languages. If you update the app strings, ensure the generated localization files are refreshed.

## 🧪 Testing

Run the test suite with:

```bash
flutter test
```

## 📦 Features in development / notes

Some modules are connected to Firebase and local persistence, so it is important to keep Firebase setup consistent when testing on different devices.

## 🤝 Contribution

Contributions are welcome. If you would like to improve the app:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📜 Notes

This project is intended as a helpful parenting companion app and can be extended with additional features such as:

- pediatric growth charts
- doctor visit tracking
- reminder customization
- health education content
- cloud sync improvements

---

Made with ❤️ for a smoother parenting experience.
