# Dynamic Agri-Logistics REST API Documentation

Base URL: `http://localhost:3000/api/v1` (or `http://10.0.2.2:3000/api/v1` for Android Emulator)

All authenticated endpoints require an `Authorization: Bearer <token>` HTTP header.

---

## 1. System Health & Status

### GET `/health`
Returns the status and health metrics of the backend server.
- **Authentication**: Public
- **Response**:
```json
{
  "status": "UP",
  "timestamp": "2026-10-27T12:00:00.000Z",
  "service": "Dynamic Agri-Logistics Backend API",
  "version": "1.0.0",
  "environment": "development"
}
```

---

## 2. Authentication

### POST `/auth/register`
Registers a new user account.
- **Payload**:
```json
{
  "fullName": "John Kamau",
  "phone": "+254700000001",
  "email": "farmer@agri.com",
  "password": "Password123!",
  "role": "FARMER"
}
```

### POST `/auth/login`
Authenticates a user and returns a JWT access token.
- **Payload**:
```json
{
  "phone": "+254700000001",
  "password": "Password123!"
}
```

### GET `/auth/me`
Fetches the currently authenticated user's profile.
- **Authentication**: Bearer Token

---

## 3. Produce Listings (Crop CRUD)

### GET `/crops`
Lists all public crop produce listings. Optional query parameters: `status`, `search`.

### POST `/crops`
Creates a new produce listing (Farmer role).
- **Payload**:
```json
{
  "cropType": "Yellow Maize (Grade A)",
  "quantityKg": 5000,
  "unit": "kg",
  "askingPricePerKg": 45,
  "location": "Nakuru North Farm",
  "description": "Harvested fresh, dry maize",
  "harvestDate": "2026-10-25T00:00:00.000Z"
}
```

### PUT `/crops/:id`
Updates an existing crop listing.

### DELETE `/crops/:id`
Deletes a crop listing.

---

## 4. Transport Bookings & Pricing

### GET `/bookings`
Retrieves transport requests.

### POST `/bookings`
Submits a new freight transport request.
- **Payload**:
```json
{
  "cropListingId": "crop-001",
  "pickupLocation": "Nakuru North Farm",
  "destinationLocation": "Nairobi Fresh Produce Hub",
  "estimatedWeight": 5000,
  "requiredVehicleType": "10-Ton Refrigerated Truck",
  "estimatedPrice": 25000
}
```

### POST `/bookings/:id/assign`
Assigns a driver and vehicle to a transport request (Agent/Admin role).

---

## 5. Driver Trips & Live Tracking

### GET `/trips/assigned`
Fetches assigned trips for the authenticated driver.

### PATCH `/trips/:id/status`
Updates trip execution state (`ASSIGNED`, `EN_ROUTE_PICKUP`, `PICKED_UP`, `IN_TRANSIT`, `ARRIVED`, `DELIVERED`).

### POST `/trips/:id/tracking`
Posts live GPS coordinate checkpoint log.
- **Payload**:
```json
{
  "latitude": -0.7167,
  "longitude": 36.4333,
  "speed": 65,
  "locationName": "A104 Highway near Naivasha",
  "notes": "In transit"
}
```

---

## 6. Deliveries & Warehouse Receipts

### GET `/deliveries/incoming`
Lists active incoming shipments destined for the receiver's hub.

### POST `/deliveries/:id/confirm`
Confirms cargo arrival and records actual received quantity and condition rating (`EXCELLENT`, `GOOD`, `ACCEPTABLE`, `DAMAGED`).
