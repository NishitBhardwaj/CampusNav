# 🧭 CampusNav

<p align="center">
  <strong>Offline-First Indoor Navigation & Personnel Locator</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Architecture-Clean-green" alt="Clean Architecture">
  <img src="https://img.shields.io/badge/Phase-0%20Foundation-orange" alt="Phase 0">
</p>

---

## 📋 Overview

CampusNav is a mobile application designed for **offline indoor navigation** within campus environments. It helps users find their way to classrooms, labs, offices, and locate faculty members - all without requiring an internet connection.

### ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🗺️ Offline Navigation | Navigate buildings without internet |
| 📍 QR Initialization | Scan QR codes to set your position |
| 🔍 Fuzzy Search | Find locations and people with smart matching |
| 👥 Personnel Locator | Find faculty offices and navigate to them |
| 🧮 A* Pathfinding | Optimal route calculation |
| 👤 Role-Based Access | User and Admin roles |
| 📝 Feedback System | Crowdsourced data verification |

---

## 🏗️ Architecture

Clean Architecture with clear separation of concerns:

```
lib/
├── core/              # Constants, utilities, services, theme
├── data/              # Models (Hive), repositories, local storage
├── domain/            # Entities, use cases, navigation logic
├── presentation/      # Screens, widgets, state (Riverpod)
├── config/            # Routes, configuration
└── main.dart          # Entry point
```

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.x |
| State Management | Riverpod |
| Local Database | Hive |
| Animations | Lottie, flutter_animate |
| Pathfinding | A* Algorithm |
| UI | Material 3 |

---

## 🚀 Getting Started

```bash
# Clone
git clone https://github.com/NishitBhardwaj/CampusNav.git
cd CampusNav

# Install dependencies
flutter pub get

# Generate Hive adapters (after adding data)
flutter pub run build_runner build

# Run
flutter run
```

---

## 📱 Screens

| Screen | Purpose |
|--------|---------|
| Splash | App initialization with animations |
| Home | Role-based navigation hub |
| Search | Find locations and people |
| Navigation | Turn-by-turn directions |
| Admin | Data entry (admin only) |

---

## 👤 Role System

| Role | Capabilities |
|------|--------------|
| **User** | View navigation, search, submit feedback |
| **Admin** | Add/edit buildings, rooms, personnel |

Toggle between roles using the app bar icon (demo mode).

---

## 📝 Feedback System

Users can verify data accuracy:
- "Is this information correct?" - Yes/No
- Optional comments for corrections
- Admin review queue
- No AI hallucination - only admin-verified data

---

## 🔮 Roadmap

- [x] Phase 0: Foundation
- [ ] Phase 1: Core features
- [ ] Phase 2: Sensor integration
- [ ] Phase 3: Backend sync

---

## 📄 License

MIT License

---

<p align="center">
  <strong>🧭 Navigate your campus with confidence!</strong>
</p>
