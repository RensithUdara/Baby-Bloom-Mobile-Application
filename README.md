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

- Flutter SDK installed and added to your PATH
- Android Studio or Xcode installed for device builds
- An emulator or physical device connected
- A Firebase project created in the Firebase console
- Internet access for Firebase and notification services

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
   - Create a Firebase project at https://console.firebase.google.com/
   - Enable the services used by the app, including:
     - Authentication
     - Firestore Database
     - Cloud Messaging
     - Analytics (optional but recommended)
   - Register your app for Android and iOS in the Firebase console
   - Download the configuration files:
     - Android: google-services.json
     - iOS: GoogleService-Info.plist
   - Place them in the correct platform folders:
     - Android: android/app/google-services.json
     - iOS: ios/Runner/GoogleService-Info.plist
   - If you are using FlutterFire, generate the configuration with:
     ```bash
     flutterfire configure
     ```
   - This project already includes Firebase initialization code in the app entry point, so the configuration files must be present before running the app

4. Run the app
   ```bash
   flutter run
   ```

## 🔥 Firebase setup guide

### 1) Create a Firebase project

1. Open the Firebase console
2. Click Add project
3. Enter your project name
4. Follow the setup prompts to create the project

### 2) Enable required Firebase services

In your Firebase project dashboard, enable:

- Authentication
- Firestore Database
- Cloud Messaging
- Analytics (recommended)

### 3) Add Android app

1. In Firebase, click Add app > Android
2. Enter the Android package name
3. Download google-services.json
4. Place it in android/app/
5. Make sure the Google services plugin is applied in android/build.gradle and android/app/build.gradle

### 4) Add iOS app

1. In Firebase, click Add app > iOS
2. Enter your iOS bundle identifier
3. Download GoogleService-Info.plist
4. Add it to the Xcode project under ios/Runner/
5. Ensure the Firebase iOS SDK is configured properly in your project

### 5) Firebase rules and Firestore setup

If you use Firestore, make sure your database rules allow read/write access for development:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

> For production, replace this with stricter rules.

### 6) Local development tips

- If Firebase initialization fails, confirm the configuration files are correctly placed
- Make sure the app package name / bundle identifier matches the values you registered in Firebase
- If you change your app ID, regenerate the Firebase config files

## 🤖 Android deployment guide

### Build prerequisites

- Install Android Studio
- Install the Android SDK
- Create or select an Android emulator or connect a physical device

### Check device connection

```bash
flutter devices
```

### Run on Android

```bash
flutter run -d <device-id>
```

### Build an APK

```bash
flutter build apk
```

### Build an App Bundle (recommended for Play Store)

```bash
flutter build appbundle
```

The generated output will be placed in:

- APK: build/app/outputs/flutter-apk/app-release.apk
- App Bundle: build/app/outputs/bundle/release/app-release.aab

### Android signing (for release builds)

Before publishing to the Play Store, create a keystore and configure signing:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then configure signing in android/app/build.gradle and upload the release bundle to Google Play.

## 🍎 iOS deployment guide

### Build prerequisites

- Install Xcode from the App Store
- Sign in with your Apple Developer account
- Set up an Apple team in Xcode

### Run on iOS simulator

```bash
flutter run
```

### Build for iOS

```bash
flutter build ios
```

### Prepare for App Store submission

1. Open ios/Runner.xcworkspace in Xcode
2. Select your signing team
3. Set the bundle identifier
4. Enable capabilities such as push notifications if required
5. Archive the app from Xcode
6. Upload the build to App Store Connect

### Important iOS notes

- Firebase services on iOS require the GoogleService-Info.plist file
- Push notifications may require APNs configuration
- If the build fails, verify the Xcode signing settings and provisioning profile

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
