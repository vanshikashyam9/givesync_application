# GiveSync 🤝

A Flutter-based donation management application built for **FoodLink**, designed to streamline the process of tracking, syncing, and reporting food donations across multiple store locations.

## Features

- **Donation Intake** — Record donations by date, store location, category, weight, and end location through an intuitive form interface
- **Cloud Sync** — Seamlessly sync local donation records with Firebase Cloud Firestore
- **Database View** — Browse, filter, and manage all donation entries with date and store filters
- **Donation Trends** — Visualize donation data with interactive charts powered by FL Chart
- **CSV Email Reports** — Generate CSV summaries for a selected date range and email them to admins/staff via Firebase Cloud Functions
- **User Authentication** — Firebase Auth with role-based access control (admin, staff, manager, volunteer)
- **Role Management** — Admin users can manage permissions and roles for all other users
- **Bug Reporting** — Built-in bug report backend for issue tracking

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter (Dart) |
| **Backend** | Firebase (Firestore, Auth, Cloud Functions, Storage) |
| **Email Service** | Nodemailer via Firebase Cloud Functions |
| **Charts** | FL Chart |
| **Platforms** | Android, iOS, Web, macOS, Linux, Windows |

## Project Structure

```
givesync_application_385/
├── lib/
│   ├── main.dart                  # App entry point
│   ├── pages/                     # App screens
│   │   ├── controller_page.dart   # Main navigation controller
│   │   ├── donation_page.dart     # Donation intake form
│   │   ├── database_page.dart     # Database view
│   │   ├── donation_trends_page.dart
│   │   ├── settings_page.dart
│   │   ├── user_login_page.dart
│   │   └── user_register_page.dart
│   ├── services/                  # Business logic
│   │   ├── donation_service.dart
│   │   ├── donation_trend_service.dart
│   │   └── user_service.dart
│   └── util/                      # Utilities & widgets
│       ├── local_database_controller.dart
│       ├── firebase_controller.dart
│       └── ...
├── functions/                     # Firebase Cloud Functions
│   └── index.js                   # Email sending endpoint
└── pubspec.yaml
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>=3.9.2)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- A Firebase project with Firestore, Auth, and Cloud Functions enabled

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/vanshikashyam9/givesync_application.git
   cd givesync_application/givesync_application_385
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS/macOS) files
   - Configure your Firebase project settings

4. **Deploy Cloud Functions**
   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Environment Variables

For Cloud Functions email sending, set the following environment variables in your Firebase project:

```bash
firebase functions:config:set gmail.email="your-email@gmail.com" gmail.password="your-app-password"
```

> **Note:** Use a [Gmail App Password](https://support.google.com/accounts/answer/185833), not your regular password.

## License

This project was developed as part of CMPT 385 coursework.
