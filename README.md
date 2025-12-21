# 🧭 CampusNav

<p align="center">
  <strong>Offline-First Indoor Navigation & Personnel Locator</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Architecture-Clean-green" alt="Clean Architecture">
  <img src="https://img.shields.io/badge/Status-Hackathon%20Ready-orange" alt="Status">
</p>

---

## 📋 Overview

CampusNav is a mobile application designed for **offline indoor navigation** within campus environments. It helps users find their way to classrooms, labs, offices, and locate faculty members - all without requiring an internet connection.

### Key Features

- 🗺️ **Offline Indoor Navigation** - Navigate buildings without internet
- 📍 **QR-Based Location Initialization** - Scan QR codes to set your position
- 🔍 **Fuzzy Search** - Find locations and people with smart matching
- 👥 **Personnel Locator** - Find faculty offices and navigate to them
- 🧮 **A* Pathfinding** - Optimal route calculation
- 📱 **Sensor-Based Tracking** - Movement tracking using device sensors
- 🏢 **Multi-Floor Support** - Navigate across floors via stairs/elevators

---

## 🏗️ Architecture

This project follows **Clean Architecture** principles for maintainability and testability.

```
lib/
├── core/              # Shared utilities, constants, services, theme
├── data/              # Data layer (models, repositories, local storage)
├── domain/            # Business logic (entities, use cases, navigation)
├── presentation/      # UI layer (screens, widgets, state)
├── config/            # App configuration and routing
└── main.dart          # Entry point
```

### Layer Description

| Layer | Purpose |
|-------|---------|
| **Core** | Constants, utilities, services (QR, sensors), theming |
| **Data** | Data models, local database, repository implementations |
| **Domain** | Business entities, use cases, A* pathfinding engine |
| **Presentation** | Screens, widgets, state management |
| **Config** | Routes, app configuration |

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.x
- Dart 3.x
- Android Studio / VS Code

### Installation

```bash
# Clone the repository
git clone https://github.com/NishitBhardwaj/CampusNav.git

# Navigate to project
cd CampusNav

# Get dependencies
flutter pub get

# Run the app
flutter run
```

---

## 📱 Screens

| Screen | Purpose |
|--------|---------|
| **Splash** | App initialization and branding |
| **Location Init** | QR code scanning for position setup |
| **Search** | Find locations and people |
| **Navigation** | Active turn-by-turn navigation |
| **Arrival** | Destination reached confirmation |
| **Fallback** | Error handling and recovery |

---

## 🧮 Technical Highlights

### A* Pathfinding
- Custom implementation for indoor navigation
- Supports multi-floor routing
- Preference options for stairs vs elevators

### Fuzzy Search
- Levenshtein distance algorithm
- Searches names, tags, and descriptions
- Configurable similarity threshold

### Offline-First Design
- All map data stored locally
- No network dependency for navigation
- Optional backend sync for updates

---

## 📁 Project Structure

```
CampusNav/
├── lib/
│   ├── core/
│   │   ├── constants/      # App-wide constants
│   │   ├── utils/          # Helper functions
│   │   ├── services/       # Core services (QR, sensors, storage)
│   │   └── theme/          # App theming
│   │
│   ├── data/
│   │   ├── models/         # Data models with serialization
│   │   ├── local/          # Local database and caching
│   │   ├── repositories/   # Repository implementations
│   │   └── mock/           # Mock data for testing
│   │
│   ├── domain/
│   │   ├── entities/       # Business entities
│   │   ├── usecases/       # Application use cases
│   │   └── navigation/     # Pathfinding and navigation logic
│   │
│   ├── presentation/
│   │   ├── screens/        # App screens
│   │   ├── widgets/        # Reusable widgets
│   │   └── state/          # State management
│   │
│   └── config/             # Routes and configuration
│
├── assets/
│   ├── maps/               # Floor plan images
│   ├── icons/              # Custom icons
│   ├── images/             # App images
│   └── qr/                 # Sample QR codes
│
└── backend/
    └── springboot/         # Optional Spring Boot backend
```

---

## 🔮 Future Roadmap

- [ ] Real sensor integration for step detection
- [ ] Camera-based QR scanning
- [ ] Voice navigation instructions
- [ ] Accessibility routing options
- [ ] Spring Boot backend integration
- [ ] Real-time location sharing
- [ ] Analytics dashboard

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| Frontend | Flutter (Dart) |
| State Management | ChangeNotifier |
| Local Storage | In-memory (extensible) |
| Pathfinding | A* Algorithm |
| Backend (Future) | Spring Boot |

---

## 📄 License

This project is open source and available under the MIT License.

---

## 👥 Team

Built for hackathon demonstration.

---

<p align="center">
  <strong>🧭 Navigate your campus with confidence!</strong>
</p>
