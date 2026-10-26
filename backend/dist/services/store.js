"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.store = void 0;
const password_1 = require("../utils/password");
class InMemoryStore {
    users = new Map();
    crops = new Map();
    bookings = new Map();
    vehicles = new Map();
    trips = new Map();
    trackingLogs = new Map();
    deliveryConfirmations = new Map();
    configs = new Map();
    initialized = false;
    async seedInitialData() {
        if (this.initialized)
            return;
        const defaultPasswordHash = await (0, password_1.hashPassword)('Password123!');
        // Admin user
        const admin = {
            id: 'usr-admin-001',
            phone: '+10000000000',
            email: 'admin@agri.com',
            password: defaultPasswordHash,
            fullName: 'System Administrator',
            role: 'ADMIN',
            isActive: true,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
        this.users.set(admin.id, admin);
        // Farmer user
        const farmer = {
            id: 'usr-farmer-001',
            phone: '+1254700000001',
            email: 'farmer@agri.com',
            password: defaultPasswordHash,
            fullName: 'John Kamau (Farmer)',
            role: 'FARMER',
            isActive: true,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
        this.users.set(farmer.id, farmer);
        // Agent user
        const agent = {
            id: 'usr-agent-001',
            phone: '+1254700000002',
            email: 'agent@agri.com',
            password: defaultPasswordHash,
            fullName: 'Sarah Wanjiku (Agent)',
            role: 'AGENT',
            isActive: true,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
        this.users.set(agent.id, agent);
        // Driver user
        const driver = {
            id: 'usr-driver-001',
            phone: '+1254700000003',
            email: 'driver@agri.com',
            password: defaultPasswordHash,
            fullName: 'David Ochieng (Driver)',
            role: 'DRIVER',
            isActive: true,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
        this.users.set(driver.id, driver);
        // Receiver user
        const receiver = {
            id: 'usr-receiver-001',
            phone: '+1254700000004',
            email: 'receiver@agri.com',
            password: defaultPasswordHash,
            fullName: 'Nairobi Fresh Produce Hub',
            role: 'RECEIVER',
            isActive: true,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
        this.users.set(receiver.id, receiver);
        // Sample Crops
        const crop1 = {
            id: 'crop-001',
            farmerId: farmer.id,
            farmerName: farmer.fullName,
            cropType: 'Maize (Grade A)',
            quantityKg: 5000,
            askingPricePerKg: 45,
            location: 'Nakuru North Farm',
            description: 'Freshly harvested yellow maize ready for dispatch',
            status: 'AVAILABLE',
            harvestDate: new Date().toISOString(),
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
        const crop2 = {
            id: 'crop-002',
            farmerId: farmer.id,
            farmerName: farmer.fullName,
            cropType: 'Red Tomatoes',
            quantityKg: 1200,
            askingPricePerKg: 80,
            location: 'Naivasha Greenhouses',
            description: 'High quality greenhouse ripe tomatoes',
            status: 'AVAILABLE',
            harvestDate: new Date().toISOString(),
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
        this.crops.set(crop1.id, crop1);
        this.crops.set(crop2.id, crop2);
        // Sample Vehicle
        const vehicle1 = {
            id: 'veh-001',
            driverId: driver.id,
            driverName: driver.fullName,
            vehicleType: '10-Ton Refrigerated Truck',
            capacityKg: 10000,
            licensePlate: 'KCF 789X',
            status: 'IDLE',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
        this.vehicles.set(vehicle1.id, vehicle1);
        // Sample Transport Booking
        const booking1 = {
            id: 'bk-001',
            requesterId: farmer.id,
            requesterName: farmer.fullName,
            cropListingId: crop1.id,
            origin: 'Nakuru North Farm',
            destination: 'Nairobi Fresh Produce Hub',
            totalWeightKg: 5000,
            vehicleTypeRequired: '10-Ton Truck',
            estimatedCost: 25000,
            status: 'MATCHED',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
        this.bookings.set(booking1.id, booking1);
        // Sample Trip
        const trip1 = {
            id: 'trip-001',
            bookingId: booking1.id,
            driverId: driver.id,
            driverName: driver.fullName,
            vehicleId: vehicle1.id,
            vehiclePlate: vehicle1.licensePlate,
            status: 'IN_TRANSIT',
            price: 25000,
            assignedAt: new Date().toISOString(),
            startedAt: new Date().toISOString(),
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
        this.trips.set(trip1.id, trip1);
        // Initial Tracking Logs for trip-001
        const logsTrip1 = [
            {
                id: 'log-001',
                tripAssignmentId: trip1.id,
                status: 'ASSIGNED',
                location: 'Nakuru Dispatch Depot',
                latitude: -0.2833,
                longitude: 36.0667,
                speed: 0,
                locationName: 'Nakuru Dispatch Depot',
                notes: 'Driver assigned to trip',
                timestamp: new Date(Date.now() - 7200000).toISOString(),
            },
            {
                id: 'log-002',
                tripAssignmentId: trip1.id,
                status: 'EN_ROUTE_PICKUP',
                location: 'Nakuru Farm Road',
                latitude: -0.2800,
                longitude: 36.0700,
                speed: 40,
                locationName: 'Nakuru Farm Road',
                notes: 'En route to pickup farm',
                timestamp: new Date(Date.now() - 5400000).toISOString(),
            },
            {
                id: 'log-003',
                tripAssignmentId: trip1.id,
                status: 'PICKED_UP',
                location: 'Nakuru North Farm',
                latitude: -0.2833,
                longitude: 36.0667,
                speed: 0,
                locationName: 'Nakuru North Farm',
                notes: 'Produce loaded onto truck',
                timestamp: new Date(Date.now() - 3600000).toISOString(),
            },
            {
                id: 'log-004',
                tripAssignmentId: trip1.id,
                status: 'IN_TRANSIT',
                location: 'A104 Highway near Naivasha',
                latitude: -0.7167,
                longitude: 36.4333,
                speed: 65,
                locationName: 'Naivasha Highway Section',
                notes: 'In transit to Nairobi Hub',
                timestamp: new Date(Date.now() - 1800000).toISOString(),
            },
        ];
        this.trackingLogs.set(trip1.id, logsTrip1);
        // System Configs
        const config1 = {
            id: 'cfg-001',
            key: 'BASE_TRANSPORT_TARIFF_PER_KM',
            value: '15.5',
            description: 'Base pricing rate per km for transport calculations',
            updatedAt: new Date().toISOString(),
        };
        const config2 = {
            id: 'cfg-002',
            key: 'AGENT_COMMISSION_PERCENT',
            value: '3.5',
            description: 'Default agent commission percentage',
            updatedAt: new Date().toISOString(),
        };
        this.configs.set(config1.id, config1);
        this.configs.set(config2.id, config2);
        this.initialized = true;
    }
}
exports.store = new InMemoryStore();
