# Dynamic Agri-Logistics: Adaptive Transport System for Volatile Markets

[![Flutter](https://img.shields.io/badge/Flutter-3.47.2-blue.svg)](https://flutter.dev)
[![React](https://img.shields.io/badge/React-18.3.1-blue.svg)](https://react.dev)
[![Node.js](https://img.shields.io/badge/Node.js-24.20.0-green.svg)](https://nodejs.org)
[![Prisma](https://img.shields.io/badge/Prisma-5.22.0-indigo.svg)](https://prisma.io)
[![Leaflet](https://img.shields.io/badge/Leaflet-1.9.4-green.svg)](https://leafletjs.com)

A runnable, integrated, end-to-end agricultural logistics platform connecting Farmers, Agents, Drivers, Receivers, and System Administrators to streamline produce transport, vehicle allocation, dynamic pricing, and spatial route tracking.

---

## 🌟 Key Features

- **Multi-Role Authentication & Access Control**: Real JWT authentication with password hashing (`bcryptjs`), role-based route protection, and normalized phone numbers (`+254...`).
- **Farmer Produce Console**: Crop listing CRUD, harvest date scheduling, and automated freight tariff calculation.
- **Agent Aggregation & Dispatch Hub**: Request review, capacity matching, driver-vehicle assignment, and regional freight management.
- **Driver & Fleet Console**: Trip assignment management, status progression (`ASSIGNED` ➔ `EN_ROUTE_PICKUP` ➔ `PICKED_UP` ➔ `IN_TRANSIT` ➔ `DELIVERED`), and live location sharing consent toggle.
- **Receiver & Warehouse Verification Log**: Active incoming shipment tracking, ETA updates, actual weight verification, condition rating (`EXCELLENT`, `GOOD`, `ACCEPTABLE`, `DAMAGED`), and discrepancy logs.
- **Interactive OpenStreetMap Integration**:
  - **Flutter App**: `flutter_map` with pickup markers, destination flags, live driver truck markers, and route polyline visualizers.
  - **Web Admin Dashboard**: Leaflet GIS map displaying real-time vehicle coordinates and shipment progress.
- **Dynamic Rule-Based Pricing Engine**: Rule-based pricing based on distance, cargo weight, vehicle capacity factor, and refrigeration surcharge.

---

## 📂 Project Structure

```
dynamic-agri-logistics/
├── mobile/                  # Flutter Cross-Platform Mobile Application
│   ├── lib/                 # Dart Models, Screens, Services, Theme
│   └── android/             # Valid Android Gradle Platform Scaffolding
├── web/                     # React + TypeScript + Vite Web Admin Dashboard
│   ├── src/                 # Components (Leaflet MapComponent), Pages, Services
│   └── index.html           # Tailwind CSS & Leaflet Head Setup
├── backend/                 # Node.js + Express + TypeScript Backend
│   ├── src/                 # Controllers, Routes, Middleware, Stores
│   ├── prisma/              # Prisma Relational Schema & Client
│   └── scripts/             # Seed & Test Suites
├── docs/                    # Architecture, API & User Guide Documentation
├── scripts/                 # PowerShell Automation Scripts (setup, start, health-check, stop)
└── PROJECT_STATUS.md        # Comprehensive Verification & Test Report
```

---

## ⚡ Quick Start

### 1. Environment Setup
Run the setup script from PowerShell:
```powershell
.\scripts\setup.ps1
```

### 2. Start Services
Launch backend API and web operations dashboard:
```powershell
.\scripts\start.ps1
```

### 3. Check Backend Health
```powershell
.\scripts\health-check.ps1
```
Or open in browser: `http://localhost:3000/api/v1/health`

### 4. Build Android Debug APK
```powershell
cd mobile
flutter build apk --debug
```
Output APK: `mobile/build/app/outputs/flutter-apk/app-debug.apk`

---

## 🔑 Default Seed Accounts

| Role | Phone | Password | Access |
| :--- | :--- | :--- | :--- |
| **FARMER** | `+1254700000001` | `Password123!` | Crop produce listings & transport requests |
| **AGENT** | `+1254700000002` | `Password123!` | Transport request review & driver dispatch |
| **DRIVER** | `+1254700000003` | `Password123!` | Trip execution & GPS tracking updates |
| **RECEIVER** | `+1254700000004` | `Password123!` | Incoming produce verification & quality logs |
| **ADMIN** | `+10000000000` | `Password123!` | Full admin console & fleet configuration |

---

## 📄 License
This project is created as a final-year Agri-Logistics software project.
