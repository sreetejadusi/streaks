<div align="center">
  <img src="assets/logo.png" width="150" alt="Streaks Logo">  
</div>

# Streaks: **A beautiful, privacy-first, completely offline habit tracker built with Flutter.**

---

## 🎯 About The Project

Streaks is a minimalist mobile application designed to help you build and maintain daily routines without compromising your data privacy.

Unlike most modern tracking applications, **Streaks operates 100% offline.** There are no cloud servers, no forced accounts, no analytics, and no hidden trackers. All your habits, streaks, and progress data are securely stored directly on your device using an encrypted local database.

### ✨ Key Features

- **Total Privacy:** Everything lives on your device. No internet connection is ever required.
- **Customizable Habits:** Create routines with custom names, daily schedules, start dates, and select from dozens of native emojis as your habit icon.
- **Dynamic Re-ordering:** Customize your dashboard hierarchy by simply dragging and dropping habits in the 'All Habits' screen.
- **Smart Dashboard:** Automatically filters and sorts your daily routine based on your chosen schedule and start dates.
- **Completion History:** True daily tracking. Mark habits as done for specific days without messing up your past or future schedules.
- **Local Reminders:** Schedule robust, on-device push notifications so you never miss a routine.
- **Data Portability:** Easily export and import your entire profile and habit history as a raw `.streaks` JSON backup file.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.12.2 or higher)
- Android Studio / Xcode for deployment

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/streaks.git
   ```
2. Navigate to the project directory:
   ```bash
   cd streaks
   ```
3. Get the required dependencies:
   ```bash
   flutter pub get
   ```
4. Generate the adaptive app icons (for Android 8.0+):
   ```bash
   flutter pub run flutter_launcher_icons
   ```
5. Run the app:
   ```bash
   flutter run
   ```

## 🔐 Privacy Policy

Because this app handles your personal daily habits, we take privacy incredibly seriously. You can review our full [Privacy Policy](PRIVACYPOLICY.md) to understand exactly how your data is kept secure on your local device.

## 🛠 Tech Stack

- **Framework:** Flutter
- **Local Database:** Hive (`hive_flutter`)
- **Notifications:** `flutter_local_notifications`
- **File Management:** `file_picker` & `path_provider`
