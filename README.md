# ✍️ e-Signature App – Flutter

A Flutter-based e-Signature mobile application developed as part of the Technical Assessment: Mobile Application Developer (Flutter).

The app allows users to upload documents, place interactive fields (signature, text, checkbox, date), export/import field configurations as JSON, and generate a finalized signed PDF.

## 🎯 Objective

This project evaluates:
- Flutter development skills
- UI/UX implementation
- Drag & drop interactions
- PDF rendering & generation
- JSON data modeling
- Firebase authentication & integration

## 📱 App Flow
```
Login / Signup
      ↓
Upload Document 
      ↓
Document Editor (Add & Place Fields)
      ↓
Signing Mode (Fill Fields)
      ↓
Generate Final PDF
```

## 🔐 Authentication (Firebase)

- Email & password login / signup
- Authentication state persists between sessions
- Non-authenticated users cannot access document features

## 📄 Document Upload

**Supported formats:**
- PDF
- DOCX

**Features:**
- Files stored locally or in Firebase Storage
- Redirects to Document Editor after upload
- Document preview shown before editing

## 🧩 Document Editor – Field Placement

### Supported Fields
- Signature
- Text
- Checkbox
- Date

### Features
- Add multiple fields of any type
- Drag & drop positioning
- Place fields anywhere on the document

## 🛠️ Tech Stack

- Flutter (latest stable)
- Dart
- Firebase Authentication
- PDF rendering & generation packages
- Drag & drop interaction 
- File picker & preview utilities

## 🧱 Architecture

- Clean & modular architecture
- Proper separation of UI, logic & services
- Scalable and maintainable project structure

## 📂 Project Structure
```
lib/
│── app/
│   ├── core/
│   │   ├── base/                # Base classes (widgets, controllers, themes)
│   │   ├── data/
│   │   │   ├── local/           # Local data sources (Hive, JSON, etc.)
│   │   │   │   └── document_local/
│   │   │   ├── remote/          # Remote APIs (HTTP, Firebase)
│   │   │   └── repository/      # Repositories (combine local + remote)
│   │   ├── network/             # Dio, http client setup
│   │   ├── services/            # Dependency injection, helpers
│   │   ├── utils/               # Constants, enums, helpers
│   │   └── widgets/             # Reusable widgets (buttons, textfields)
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── domain/
│   │   │   │   └── models/      # Auth models
│   │   │   └── presentation/
│   │   │       ├── bloc/        # Auth BLoC
│   │   │       └── view/        # Auth screens/widgets
│   │   │
│   │   ├── document/
│   │   │   ├── domain/
│   │   │   │   └── models/      # Document models
│   │   │   ├── data/            # Optional: local/remote sources specific to document
│   │   │   └── presentation/
│   │   │       ├── bloc/        # document_editor_bloc, events, states
│   │   │       └── view/        # screens & widgets
│   │   │
│   │   └── home/                 # Home feature (domain + presentation)
│   │
│   ├── route/                     # App routing
│   └── flavors/                   # Multiple environment configs (dev, prod)
│
├── main.dart                      # App entry point
├── main_dev.dart                   # Dev flavor
└── main_prod.dart                  # Prod flavor
```

## 🖥️ Environment

- **Flutter:** 3.35.4
- **Dart:** 3.9.2
- **DevTools:** 2.48.0

## 📦 Download APK

You can download and test the latest build of the app from Google Drive:

👉 [Download APK](https://drive.google.com/file/d/19r1gZeDnJL984D71AB5Amrc3azEvE3al/view?usp=sharing)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.35.4 or higher)
- Dart SDK (3.9.2 or higher)
- Firebase project setup

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/e-signature-app.git
cd e-signature-app
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`

4. Run the app
```bash
flutter run
```

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for authentication services
- All open-source packages used in this project
