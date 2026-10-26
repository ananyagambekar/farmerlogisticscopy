# Dynamic Agri-Logistics System Architecture

## Overview
**Dynamic Agri-Logistics: Adaptive Transport System for Volatile Markets** is an enterprise cross-platform agricultural supply chain platform connecting smallholder Farmers, Aggregators/Agents, Transporters/Drivers, Produce Receivers/Hubs, and Operations Administrators.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           Client Applications                           │
├───────────────────────────────────┬─────────────────────────────────────┤
│ Mobile App (Flutter Dart / Android)│ Web Dashboard (React + Vite + TS)   │
│ - Farmers, Agents, Drivers,       │ - Admin & Regional Operations       │
│   Receivers                       │ - Users, Crops, Bookings, System    │
└─────────────────┬─────────────────┴──────────────────┬──────────────────┘
                  │                                    │
                  │ REST API (HTTPS/JWT)               │
                  ▼                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    Express REST API (TypeScript)                        │
│ - JWT Authentication, Role Guards, Phone Normalization, Rate Limiter    │
├──────────────┬──────────────┬──────────────┬──────────────┬─────────────┤
│ Auth Module  │ Users Module │ Crops Module │ Bookings     │ Trips Engine│
└──────────────┴──────┬───────┴──────────────┴──────┬───────┴──────┬──────┘
                      │                             │              │
                      ▼                             ▼              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         Prisma ORM / PostgreSQL                         │
│ - User, CropListing, TransportBooking, DriverVehicle, TripAssignment,   │
│   DeliveryStatusLog, SystemConfig                                       │
└─────────────────────────────────────────────────────────────────────────┘
```

## Monorepo Directory Layout
```
/farmerlogistics
├── backend/                  # Express REST API + Prisma ORM + TypeScript
│   ├── prisma/
│   │   └── schema.prisma     # PostgreSQL data schema
│   ├── src/
│   │   ├── controllers/      # Auth, User, Crop, Booking, Trip, Vehicle, Config
│   │   ├── middleware/       # JWT Auth, Role Guard, Rate Limiter, Validation
│   │   ├── routes/           # REST endpoints
│   │   ├── services/         # State store & seed manager
│   │   └── utils/            # Phone normalization, Password hashing, JWT
│   └── scripts/              # Seeding scripts
├── mobile/                   # Flutter cross-platform mobile app
│   ├── lib/
│   │   ├── models/           # User, Crop, Booking, Trip, Vehicle models
│   │   ├── screens/          # Role-based dashboards (Farmer, Agent, Driver, Receiver, Admin)
│   │   ├── services/         # API Service & Auth State Provider
│   │   └── theme/            # Agricultural green, white, earthy M3 design
│   └── test/                 # Unit & widget tests
├── web/                      # React + TypeScript + Vite Web Console
│   └── src/
│       ├── components/       # Navbar, Sidebar, ProtectedRoute
│       ├── pages/            # Dashboard, Users, Crops, Bookings, Trips, Settings
│       └── services/         # API Client
├── docs/                     # Architecture, API & User guides
└── scripts/                  # PowerShell orchestration scripts (setup, start, health-check, stop)
```

## Database Entity Relationship & Roles Matrix

### Models
1. **User**: `id`, `phone` (unique), `email` (unique), `password` (hashed), `fullName`, `role` (`FARMER` | `AGENT` | `DRIVER` | `RECEIVER` | `ADMIN`), `isActive`, `createdAt`, `updatedAt`.
2. **CropListing**: `id`, `farmerId`, `cropType`, `quantityKg`, `askingPricePerKg`, `location`, `status`, `harvestDate`.
3. **TransportBooking**: `id`, `requesterId`, `cropListingId`, `origin`, `destination`, `totalWeightKg`, `vehicleTypeRequired`, `estimatedCost`, `status`.
4. **DriverVehicle**: `id`, `driverId`, `vehicleType`, `capacityKg`, `licensePlate`, `status`.
5. **TripAssignment**: `id`, `bookingId`, `driverId`, `vehicleId`, `status`, `price`, `assignedAt`, `startedAt`, `completedAt`.
6. **DeliveryStatusLog**: `id`, `tripAssignmentId`, `status`, `location`, `notes`, `timestamp`.
7. **SystemConfig**: `id`, `key` (unique), `value`, `description`.

### Role Permissions
- **FARMER**: Create and manage crop listings; request transport bookings for produce.
- **AGENT**: Aggregate produce from multiple farmers; book combined transport; track commissions.
- **DRIVER**: Register vehicles; receive trip assignments; update vehicle status and delivery logs in transit.
- **RECEIVER**: View incoming produce shipments; verify and confirm produce quality upon arrival.
- **ADMIN**: Access system metrics, manage user statuses, modify dynamic system pricing configurations. Cannot be registered publicly via mobile API.
