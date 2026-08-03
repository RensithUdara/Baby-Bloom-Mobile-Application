# 🌸 BabyBloom

BabyBloom is a modern Flutter app for mothers, parents, and caregivers to manage baby health records, vaccine reminders, growth tracking, MOH clinic details, and daily care support in one calm, friendly place.

## ✨ What BabyBloom Offers

- 👶 Baby profile management with birth details
- 💉 Vaccine schedule tracking
- ➕ Custom vaccine adding for extra or clinic-specific vaccines
- ✅ Mark vaccines as completed
- 🔔 Local vaccine reminders and Firebase push notification support
- 🕘 Reminder time and notification settings
- 📅 Calendar view for vaccines and personal reminders
- 📈 Growth chart records for weight, height, and BMI
- 🏥 MOH clinic details and health guidance
- 🚨 National emergency numbers and personal emergency contacts
- 📜 Child immunization certificate
- 🗂️ Notification history
- 🌙 Light and dark mode
- 🌍 Multi-language support
- 🔐 Firebase authentication
- 🎨 Redesigned settings, popups, support, privacy, and about pages

## 🧩 Main Features

### 👶 Baby Profiles

Add and manage baby details including name, date of birth, gender, blood group, birth weight, hospital, and profile information.

### 💉 Vaccine Tracking

BabyBloom creates vaccine records based on the baby's profile and lets mothers track each vaccine as pending, overdue, upcoming, or completed.

### ➕ Add Custom Vaccines

Some mothers may need to add vaccines that are not already in the default list. The app now supports adding a custom vaccine with:

- Vaccine name
- Dose number
- Due date
- Automatic pending status
- Reminder scheduling support

### 🔔 Notifications & Reminders

The app supports vaccine reminders and push notifications:

- 3 days before due date
- 1 day before due date
- On the due date
- Firebase foreground and background push handling
- Notification history screen
- Notification enable/disable setting
- Android exact alarm fallback support

### 📅 Calendar & Personal Reminders

The calendar shows vaccine events and user-created reminders. Mothers can add personal reminders such as clinic visits, doctor appointments, or follow-up checks.

### 📈 Growth Tracking

Track baby growth records with:

- Weight
- Height
- BMI
- Growth chart visualization
- Entry history

### 📜 Vaccine Certificate

The certificate screen shows completed vaccines in a clean child immunization certificate view, including baby details, completed count, pending count, and vaccine completion dates.

### 🏥 MOH Clinic Support

BabyBloom includes MOH clinic information and health support screens to help mothers quickly find useful clinic-related details.

### 🚨 Emergency Contacts

The app includes national emergency numbers and lets users save personal emergency contacts such as family members, doctors, or midwives.

### ⚙️ Settings

The settings screen includes:

- Language selection
- Dark mode toggle
- Notification toggle
- Reminder time picker
- Signed-in account details
- Sign out
- About, privacy, and help/support links

### 🌙 Dark Mode

The full app supports dark mode with theme-aware cards, sheets, input fields, filter chips, certificate views, splash screen, and popup designs.

## 🛠️ Tech Stack

- Flutter
- Dart
- Firebase Auth
- Firebase Cloud Firestore
- Firebase Messaging
- Firebase Analytics
- SQLite with `sqflite`
- Shared Preferences
- Flutter Local Notifications
- Material Design

## 📁 Project Structure

```text
lib/
  data/            # notification helpers, Firebase content, static data
  database/        # SQLite database layer
  l10n/            # localization files
  models/          # app data models
  screens/         # app pages and flows
  theme/           # theme, colors, text styles
  utils/           # utility services and helpers
  widgets/         # reusable UI components
```

## ✅ Requirements

Before running the app, make sure you have:

- Flutter SDK installed
- Android Studio or Xcode for device builds
- An emulator or physical device
- A Firebase project
- Internet access for Firebase services

## ▶️ Getting Started

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

- Create a Firebase project
- Enable Authentication
- Enable Firestore Database
- Enable Cloud Messaging
- Add Android and/or iOS app configuration files
- Generate `firebase_options.dart` if needed:

```bash
flutterfire configure
```

4. Run the app

```bash
flutter run
```

## 🔥 Firebase Notes

BabyBloom uses Firebase for:

- User authentication
- Cloud Firestore data sync helpers
- Firebase Cloud Messaging
- Analytics

Make sure the Firebase configuration files match the app package name and bundle identifier used in your local project.

## 🔔 Notification Notes

For vaccine reminders to work correctly:

- Allow notification permission on the device
- Keep notifications enabled in the app settings
- On Android, exact alarm permission may be requested
- If exact alarms are unavailable, the app falls back to inexact reminders

## 🌍 Localization

The app supports multiple languages through Flutter localization files. When updating user-facing strings, refresh generated localization files if needed.

## 🧪 Useful Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## 🧡 Purpose

BabyBloom is built as a caring companion for mothers and families. It helps organize baby health records, reminders, emergency contacts, and vaccine progress, while keeping the experience simple, soft, and supportive.

---

Made with ❤️ for mothers, babies, and smoother everyday care.
