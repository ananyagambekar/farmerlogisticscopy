# Dynamic Agri-Logistics System Architecture

## 1. Executive System Overview

The **Dynamic Agri-Logistics System** is an adaptive, multi-tenant agricultural logistics platform designed to optimize produce transportation, reduce post-harvest losses, provide real-time spatial route tracking, and deliver transparent pricing across volatile regional produce markets.

The system connects five primary stakeholder roles through a unified micro-service backend:
1. **Farmer**: Lists harvested produce, requests freight transport, receives automated fare quotes, and tracks live dispatch.
2. **Agent**: Aggregates produce listings, reviews freight requests, assigns verified drivers & vehicles, and manages regional dispatch.
3. **Driver**: Manages assigned trips, tracks route turn-by-turn with GPS status streams, updates dispatch states, and consents to live GPS tracking.
4. **Receiver (Hub/Market)**: Inspects incoming shipments, records actual received cargo weight, rate cargo quality, and logs discrepancy reports.
5. **Administrator**: Oversees system health, user account permissions, vehicle fleet registers, and dynamic tariff algorithms.

---

## 2. Monorepo Architecture Blueprint

```
dynamic-agri-logistics/
├── mobile/                  # Flutter Cross-Platform Mobile Application
│   ├── lib/
│   │   ├── main.dart        # Entry point with Role-based Provider Routing
│   │   ├── models/          # Data Models (User, Crop, Booking, Trip, Vehicle)
│   │   ├── screens/         # Role Dashboards & Live Tracking Console
│   │   ├── services/        # HTTP API Service Layer
│   │   └── theme/           # App Material 3 Theme & Color Palette
│   └── android/             # Native Android Platform Scaffolding (Gradle & Manifest)
│
├── web/                     # React + TypeScript + Vite Admin Web Dashboard
│   ├── src/
│   │   ├── components/      # UI Layout, Navigation & Leaflet Map Components
│   │   ├── pages/           # Admin Pages (Live Tracking, Crops, Bookings, Users)
│   │   └── services/        # Axios / Fetch API Service Wrapper
│   ├── index.html           # Leaflet CSS & Tailwind UI Head Setup
│   └── package.json
│
├── backend/                 # Node.js + TypeScript + Express.js REST Service
│   ├── src/
│   │   ├── controllers/     # Auth, Crops, Bookings, Trips, Deliveries, Vehicles
│   │   ├── middleware/      # JWT Authentication, Role Guards, Rate Limiting
│   │   ├── services/        # Persistence Store & Prisma Database Service
│   │   └── utils/           # Password Hashing, JWT Sign, Phone Normalizer
│   ├── prisma/
│   │   └── schema.prisma    # PostgreSQL Relational Data Schema
│   └── package.json
│
├── docs/                    # Architecture, API & User Guide Documentation
├── scripts/                 # PowerShell Automation Scripts (setup, start, stop)
├── .env.example
├── README.md
└── PROJECT_STATUS.md
```

---

## 3. Data Flow & Communication Lifecycle

1. **Produce Listing & Request Creation**:
   - Farmer logs in and creates a produce listing (e.g. 5,000 kg Grade A Yellow Maize).
   - Farmer requests freight dispatch by providing pickup and destination locations.
   - The backend rule engine executes dynamic pricing calculations based on distance, weight, and vehicle refrigeration factor.

2. **Agent Review & Driver Dispatch**:
   - Regional Agent sees pending transport requests on their Hub Dashboard.
   - Agent reviews request requirements and assigns an available driver and registered vehicle (e.g., 10-Ton Refrigerated Truck `KCF 789X`).
   - The booking transitions from `REQUESTED` to `ASSIGNED`.

3. **Driver Execution & GPS Streaming**:
   - Driver sees assigned trip on their Driver Console.
   - Driver advances trip state: `ASSIGNED` ➔ `EN_ROUTE_PICKUP` ➔ `PICKED_UP` ➔ `IN_TRANSIT` ➔ `ARRIVED` ➔ `DELIVERED`.
   - Live location updates stream to `delivery_status_logs` and render on the interactive map (`flutter_map` on mobile and `Leaflet` on web).

4. **Receiver Verification & Settlement**:
   - Receiver at Nairobi Fresh Produce Hub views incoming produce shipments with estimated arrival times.
   - Upon arrival, Receiver verifies received weight, selects condition rating (`EXCELLENT`, `GOOD`, `ACCEPTABLE`, `DAMAGED`), and submits confirmation.
   - Produce status automatically updates to `SOLD`.

---

## 4. Map & GIS Integration Strategy

- **Web Map**: Uses Leaflet JS with OpenStreetMap tile layer (`https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png`).
- **Mobile Map**: Uses `flutter_map` with `latlong2` package.
- **Markers & Routing**:
  - Green Marker `P`: Pickup Point (Origin)
  - Red Marker `D`: Delivery Point (Destination)
  - Blue Marker `🚛`: Live Vehicle / Driver Position
  - Polyline: Spatial route visualizer between pickup, driver position, and destination.
