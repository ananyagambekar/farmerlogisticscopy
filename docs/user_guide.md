# User Onboarding & Operations Guide

## Getting Started
The Dynamic Agri-Logistics platform provides adaptive agricultural transport and marketplace management tailored for volatile supply chains.

### Default Test Accounts
- **Administrator Console (Web)**: Phone: `+10000000000` | Password: `Password123!`
- **Farmer User (Mobile)**: Phone: `+1254700000001` | Password: `Password123!`
- **Agent / Aggregator (Mobile)**: Phone: `+1254700000002` | Password: `Password123!`
- **Transporter Driver (Mobile)**: Phone: `+1254700000003` | Password: `Password123!`
- **Produce Receiver (Mobile)**: Phone: `+1254700000004` | Password: `Password123!`

---

## Mobile Application User Flows

### 1. Registration & Authentication
1. Launch the mobile application.
2. Select **Register Here**.
3. Choose your participant role: `FARMER`, `AGENT`, `DRIVER`, or `RECEIVER`.
4. Enter your Full Name, Phone Number, and Password.
5. Tap **Complete Registration**. The application will automatically authenticate and present your dedicated role dashboard.

### 2. Farmer Workflow
- **Listing Produce**: Tap **List Crop** on the dashboard, enter crop details (e.g. Maize, 5,000 kg, KES 45/kg), and confirm.
- **Requesting Transport**: Tap **Book Transport** to request logistics dispatch for your harvested produce.

### 3. Driver & Fleet Console
- **Status Toggle**: Switch your vehicle status between `IDLE` and `IN_TRANSIT`.
- **Active Trip Delivery**: View assigned pickup & destination locations. Update status to `AT_DELIVERY` upon arrival.

### 4. Agent & Aggregator
- View aggregated produce weight, track commissions, and coordinate logistics between farmers and regional distribution hubs.

---

## Web Operations Dashboard

1. Open `http://localhost:5173` in your browser.
2. Log in with Admin credentials (`+10000000000` / `Password123!`).
3. Access real-time operational tabs:
   - **Dashboard**: System overview and metric KPIs.
   - **Users & Roles**: Manage and toggle user account statuses.
   - **Crop Listings & Transport Bookings**: Inspect active supply chain activity.
   - **System Config**: Adjust dynamic tariff and commission parameters.
