# 🎓 Madrasati (مدرستي) - Next-Generation Learning Platform

**Madrasati** is a modern, gamified educational platform built with **Flutter** and **Firebase**. Designed to make learning engaging for students while providing powerful, seamless content management tools for educators and administrators. 

Whether it's managing complex lesson plans, reviewing student analytics, or completing an interactive winding-path learning level, Madrasati delivers a premium, highly responsive experience across mobile and web.

---

## ✨ Key Features

### 🧑‍🎓 For Students (Mobile-First Experience)
- **Gamified Level Maps:** A beautiful, winding-path UI inspired by top language-learning apps. Levels are locked until previous thresholds are met.
- **Interactive Lessons:** Rich, swipeable lesson cards that introduce concepts step-by-step before testing.
- **Dynamic Testing Engine:** Support for multiple question types:
  - Multiple Choice Questions (MCQ)
  - Fill-in-the-Blanks (Drag & Drop or Tap to Fill)
- **Reward System:** Earn XP, collect stars ⭐, and track best scores to unlock new categories.
- **Live Leaderboard:** Competitive rankings based on total XP to keep students motivated and engaged.

### 👨‍🏫 For Teachers (Responsive Web Dashboard)
- **Content Management:** Create and organize Categories, Levels, Lessons, and interactive Questions.
- **Bulk CSV Import:** Instantly build entire curriculums by uploading structured CSV files.
- **Real-Time Analytics:** Track student progress, identify the most frequently failed questions, and view average pass rates per level.
- **Activity Logs:** A real-time chronological feed of system events (e.g., student registrations, new content added).

### 🛡️ For Administrators (Web Portal)
- **User Management:** Oversee all platform users.
- **Registration Approvals:** Securely review and approve/reject pending teacher or student registration requests.
- **System Overview:** High-level metrics on total active users, teachers, students, and content density.

---

## 🛠️ Technology Stack

- **Frontend:** [Flutter](https://flutter.dev/) (Cross-platform: iOS, Android, Web)
- **State Management:** [BLoC Pattern](https://bloclibrary.dev/) (Predictable, scalable state logic)
- **Backend/Database:** [Firebase Firestore](https://firebase.google.com/docs/firestore) (NoSQL Realtime Database)
- **Authentication:** [Firebase Auth](https://firebase.google.com/docs/auth)
- **Routing:** [GoRouter](https://pub.dev/packages/go_router) (Declarative deep-linking and web routing)
- **Data Parsing:** `csv` & `file_picker` for seamless data ingestion.

---

## 🏗️ Architecture

The project strictly follows **Clean Architecture** principles and **Feature-Driven Structure**:

```text
lib/
├── core/                   # Shared utilities, themes, routing, and constants
│   ├── router/             # GoRouter configuration
│   ├── theme/              # Centralized AppColors and AppTextStyles
│   └── utils/              # Network info, Activity logger, formatters
├── features/               # Isolated feature modules
│   ├── admin_panel/        # Admin web dashboard
│   ├── auth/               # Login, Registration, and Approval logic
│   ├── categories/         # Subject/Course selection
│   ├── home/               # Student landing page
│   ├── leaderboard/        # Global XP rankings
│   ├── lesson/             # Lesson viewer engine
│   ├── level_map/          # Winding path UI & level progression
│   ├── result/             # Post-test scoring and animations
│   ├── teacher_panel/      # Teacher web dashboard & content editors
│   └── test_engine/        # Question rendering & evaluation logic
└── main.dart               # Entry point
```
*Every feature module is divided into `data` (repositories/models) and `presentation` (blocs/widgets/screens).*

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest stable version)
- A Firebase Project configured for iOS, Android, and Web.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Moses-Ball10/madrasati.git
   cd madrasati
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   Ensure your `firebase_options.dart` is correctly set up using the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/).

4. **Run the App:**
   - For Mobile: `flutter run`
   - For Web Dashboard (Recommended for Teachers/Admins): `flutter run -d chrome`

---

## 📊 CSV Import Guide (For Teachers)
To quickly populate levels and lessons, teachers can use the **CSV Import** tool. Ensure your file is structured exactly with the following 6 columns:

| Level Title (العنوان) | Level XP | Pass Threshold | Lesson Title (الدرس) | Lesson Content (المحتوى) | Lesson Emoji |
|-----------------------|----------|----------------|----------------------|--------------------------|--------------|
| المستوى 1               | 100      | 70             | الدرس الأول          | هذا هو محتوى الدرس...   | 📖            |

*The system will automatically group lessons under the same level if the Level Title matches.*

---

## 🤝 Contributing
We believe in building educational tools that make an impact. If you'd like to contribute:
1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---
*Built with ❤️ to make education interactive, accessible, and fun.*
