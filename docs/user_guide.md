# Dynamic Agri-Logistics User & Quickstart Guide

Welcome to the **Dynamic Agri-Logistics Platform**. This guide provides step-by-step instructions to run, navigate, and test the mobile application, web dashboard, and backend services.

---

## 1. Quickstart - Running the Project

### Prerequisites
- Node.js v18+ and NPM v9+
- Flutter SDK v3.19+ (with Android SDK installed)
- PowerShell (Windows) or Terminal (macOS/Linux)

### Step 1: Environment Setup
Run the setup script from PowerShell at the project root:
```powershell
.\scripts\setup.ps1
```
This script will:
- Check required CLI tools (Node, NPM, Flutter)
- Install backend and web dependencies
- Generate Prisma Client ORM files
- Configure Android `local.properties` with SDK paths

### Step 2: Start All Services
Launch backend and web services in background processes:
```powershell
.\scripts\start.ps1
```
Service Endpoints:
- **Backend API**: `http://localhost:3000/api/v1`
- **Health Check**: `http://localhost:3000/api/v1/health`
- **Web Admin Dashboard**: `http://localhost:5173`

---

## 2. Default Seed Accounts for Testing

| Role | Phone Number | Password | Purpose / Access |
| :--- | :--- | :--- | :--- |
| **FARMER** | `+1254700000001` | `Password123!` | Create produce listings, request transport, view quotes |
| **AGENT** | `+1254700000002` | `Password123!` | Review requests, assign drivers & vehicles, manage dispatch |
| **DRIVER** | `+1254700000003` | `Password123!` | View assigned trips, advance status, share live location |
| **RECEIVER** | `+1254700000004` | `Password123!` | View incoming produce, verify cargo weight, rate quality |
| **ADMIN** | `+10000000000` | `Password123!` | Full system operations, user management, tariff configs |

---

## 3. Running the Flutter Mobile App

1. Start an Android Emulator in Android Studio or connect a physical Android device.
2. Navigate to the mobile directory and run:
```powershell
cd mobile
flutter run
```
3. To build a standalone debug Android APK file:
```powershell
cd mobile
flutter build apk --debug
```
The generated APK will be located at:
`mobile/build/app/outputs/flutter-apk/app-debug.apk`

---

## 4. Operational Workflows

### A. Farmer Workflow
1. Log in with `+1254700000001` / `Password123!`.
2. On the **My Produce** tab, tap **List New Crop**.
3. Enter crop details (e.g. 5,000 kg Yellow Maize at KES 45/kg).
4. Go to **Request Freight** tab, choose vehicle type (e.g. 10-Ton Refrigerated Truck), and view auto-calculated fare.
5. Submit transport request.

### B. Agent Workflow
1. Log in with `+1254700000002` / `Password123!`.
2. On the **Incoming Requests** tab, view incoming farmer bookings.
3. Tap **Review & Dispatch Driver**, select driver David Ochieng and vehicle `KCF 789X`.
4. Tap **Accept & Dispatch**.

### C. Driver Workflow
1. Log in with `+1254700000003` / `Password123!`.
2. Open assigned trip console and view pickup/destination route on the interactive map.
3. Advance status from `ASSIGNED` ➔ `EN_ROUTE_PICKUP` ➔ `IN_TRANSIT` ➔ `DELIVERED`.

### D. Receiver Workflow
1. Log in with `+1254700000004` / `Password123!`.
2. View incoming produce on the **Incoming Shipments** tab.
3. Tap **Verify & Receive Shipment**, input received weight, select condition rating (`EXCELLENT`), and confirm receipt.
