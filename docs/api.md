# Dynamic Agri-Logistics REST API Documentation

Base URL: `http://localhost:3000/api/v1`

## Health Check
- `GET /health`
  - Returns server operational status, environment, and version.

## Authentication Endpoints
- `POST /auth/register`
  - Request Body: `{ "fullName": "John Kamau", "phone": "+254700000001", "email": "farmer@agri.com", "password": "Password123!", "role": "FARMER" }`
  - Allowed roles: `FARMER`, `AGENT`, `DRIVER`, `RECEIVER`. (`ADMIN` rejected).
  - Response: `{ "success": true, "data": { "token": "JWT_TOKEN", "user": { ... } } }`

- `POST /auth/login`
  - Request Body: `{ "phone": "+254700000001", "password": "Password123!" }`
  - Response: `{ "success": true, "data": { "token": "JWT_TOKEN", "user": { ... } } }`

- `GET /auth/me`
  - Headers: `Authorization: Bearer <token>`
  - Response: `{ "success": true, "data": { ...userProfile } }`

## User Management (Admin Only)
- `GET /users` (Header: `Authorization: Bearer <admin_token>`)
- `GET /users/:id`
- `PATCH /users/:id/status` Body: `{ "isActive": false }`

## Crop Listings
- `GET /crops`
- `POST /crops` Body: `{ "cropType": "Maize", "quantityKg": 5000, "askingPricePerKg": 45, "location": "Nakuru" }`
- `PATCH /crops/:id/status` Body: `{ "status": "SOLD" }`

## Transport Bookings
- `GET /bookings`
- `POST /bookings` Body: `{ "origin": "Nakuru", "destination": "Nairobi", "totalWeightKg": 5000, "vehicleTypeRequired": "10-Ton Truck" }`
- `PATCH /bookings/:id/status` Body: `{ "status": "MATCHED" }`

## Trip Assignments
- `GET /trips`
- `POST /trips` Body: `{ "bookingId": "bk-001", "driverId": "usr-driver-001", "vehicleId": "veh-001", "price": 25000 }`
- `PATCH /trips/:id/status` Body: `{ "status": "IN_TRANSIT" }`

## System Configurations (Admin Only)
- `GET /system-configs`
- `PUT /system-configs/:key` Body: `{ "value": "18.0", "description": "Updated tariff" }`
