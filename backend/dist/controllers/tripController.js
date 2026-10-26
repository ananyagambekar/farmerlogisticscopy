"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getTrips = getTrips;
exports.getAssignedTrips = getAssignedTrips;
exports.getTripById = getTripById;
exports.createTrip = createTrip;
exports.updateTripStatus = updateTripStatus;
exports.addTrackingLog = addTrackingLog;
exports.getTripTrackingLogs = getTripTrackingLogs;
const store_1 = require("../services/store");
function enrichTrip(trip) {
    const booking = store_1.store.bookings.get(trip.bookingId);
    const crop = booking?.cropListingId ? store_1.store.crops.get(booking.cropListingId) : undefined;
    const driver = store_1.store.users.get(trip.driverId);
    const vehicle = store_1.store.vehicles.get(trip.vehicleId);
    const logs = store_1.store.trackingLogs.get(trip.id) || [];
    const latestLog = logs.length > 0 ? logs[logs.length - 1] : undefined;
    return {
        ...trip,
        booking: booking ? {
            ...booking,
            crop: crop ? {
                id: crop.id,
                cropType: crop.cropType,
                quantityKg: crop.quantityKg,
                askingPricePerKg: crop.askingPricePerKg,
                location: crop.location,
                status: crop.status,
            } : undefined,
        } : undefined,
        driver: driver ? {
            id: driver.id,
            fullName: driver.fullName,
            phone: driver.phone,
        } : undefined,
        vehicle: vehicle ? {
            id: vehicle.id,
            vehicleType: vehicle.vehicleType,
            capacityKg: vehicle.capacityKg,
            licensePlate: vehicle.licensePlate,
        } : undefined,
        deliveryStatusLogs: logs,
        latestLog,
    };
}
async function getTrips(req, res) {
    await store_1.store.seedInitialData();
    const list = Array.from(store_1.store.trips.values()).map(enrichTrip);
    return res.status(200).json({ success: true, count: list.length, data: list });
}
async function getAssignedTrips(req, res) {
    await store_1.store.seedInitialData();
    const driverId = req.user?.userId;
    const role = req.user?.role;
    const showAll = req.query.all === 'true' || role === 'ADMIN' || role === 'AGENT';
    let list = Array.from(store_1.store.trips.values());
    if (!showAll && driverId) {
        list = list.filter((t) => t.driverId === driverId);
    }
    const enrichedList = list.map(enrichTrip);
    return res.status(200).json({ success: true, count: enrichedList.length, data: enrichedList });
}
async function getTripById(req, res) {
    await store_1.store.seedInitialData();
    const { id } = req.params;
    const trip = store_1.store.trips.get(id);
    if (!trip) {
        return res.status(404).json({ success: false, message: 'Trip assignment not found' });
    }
    const enriched = enrichTrip(trip);
    return res.status(200).json({ success: true, data: enriched });
}
async function createTrip(req, res) {
    await store_1.store.seedInitialData();
    const { bookingId, driverId, vehicleId, price } = req.body;
    if (!bookingId || !driverId || !vehicleId) {
        return res.status(400).json({ success: false, message: 'bookingId, driverId, vehicleId are required' });
    }
    const driver = store_1.store.users.get(driverId);
    const vehicle = store_1.store.vehicles.get(vehicleId);
    const newTrip = {
        id: `trip-${Date.now()}`,
        bookingId,
        driverId,
        driverName: driver?.fullName || 'Driver',
        vehicleId,
        vehiclePlate: vehicle?.licensePlate || 'PLATE-001',
        status: 'ASSIGNED',
        price: Number(price || 15000),
        assignedAt: new Date().toISOString(),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
    };
    store_1.store.trips.set(newTrip.id, newTrip);
    // Initial status log
    const initialLog = {
        id: `log-${Date.now()}`,
        tripAssignmentId: newTrip.id,
        status: 'ASSIGNED',
        location: 'Trip Dispatch Assigned',
        notes: 'Driver assigned to transport booking',
        timestamp: new Date().toISOString(),
    };
    store_1.store.trackingLogs.set(newTrip.id, [initialLog]);
    // update booking status
    const booking = store_1.store.bookings.get(bookingId);
    if (booking) {
        booking.status = 'MATCHED';
        store_1.store.bookings.set(bookingId, booking);
    }
    return res.status(201).json({ success: true, message: 'Trip assigned successfully', data: enrichTrip(newTrip) });
}
async function updateTripStatus(req, res) {
    await store_1.store.seedInitialData();
    const { id } = req.params;
    const { status, location, locationName, latitude, longitude, speed, notes } = req.body;
    const trip = store_1.store.trips.get(id);
    if (!trip) {
        return res.status(404).json({ success: false, message: 'Trip assignment not found' });
    }
    const validStatuses = [
        'ASSIGNED',
        'EN_ROUTE_PICKUP',
        'PICKED_UP',
        'AT_PICKUP',
        'IN_TRANSIT',
        'ARRIVED',
        'AT_DELIVERY',
        'DELIVERED',
        'COMPLETED',
        'CANCELLED',
    ];
    if (status && !validStatuses.includes(status)) {
        return res.status(400).json({ success: false, message: `Invalid trip status: ${status}` });
    }
    if (status) {
        trip.status = status;
        if ((status === 'IN_TRANSIT' || status === 'EN_ROUTE_PICKUP' || status === 'PICKED_UP') && !trip.startedAt) {
            trip.startedAt = new Date().toISOString();
        }
        if ((status === 'DELIVERED' || status === 'COMPLETED') && !trip.completedAt) {
            trip.completedAt = new Date().toISOString();
        }
        trip.updatedAt = new Date().toISOString();
        store_1.store.trips.set(id, trip);
        // Synchronize associated booking status
        const booking = store_1.store.bookings.get(trip.bookingId);
        if (booking) {
            if (['EN_ROUTE_PICKUP', 'PICKED_UP', 'AT_PICKUP', 'IN_TRANSIT', 'ARRIVED', 'AT_DELIVERY'].includes(status)) {
                booking.status = 'IN_TRANSIT';
            }
            else if (status === 'DELIVERED' || status === 'COMPLETED') {
                booking.status = 'DELIVERED';
            }
            else if (status === 'CANCELLED') {
                booking.status = 'CANCELLED';
            }
            store_1.store.bookings.set(booking.id, booking);
        }
        // Append status change log
        const locStr = locationName || location || 'Location updated';
        const newLog = {
            id: `log-${Date.now()}`,
            tripAssignmentId: trip.id,
            status: trip.status,
            location: locStr,
            latitude: latitude != null ? Number(latitude) : undefined,
            longitude: longitude != null ? Number(longitude) : undefined,
            speed: speed != null ? Number(speed) : undefined,
            locationName: locStr,
            notes: notes || `Trip status updated to ${status}`,
            timestamp: new Date().toISOString(),
        };
        const logs = store_1.store.trackingLogs.get(trip.id) || [];
        logs.push(newLog);
        store_1.store.trackingLogs.set(trip.id, logs);
    }
    return res.status(200).json({ success: true, message: 'Trip status updated', data: enrichTrip(trip) });
}
async function addTrackingLog(req, res) {
    await store_1.store.seedInitialData();
    const { id } = req.params;
    const { latitude, longitude, speed, locationName, location, notes } = req.body;
    const trip = store_1.store.trips.get(id);
    if (!trip) {
        return res.status(404).json({ success: false, message: 'Trip assignment not found' });
    }
    const locStr = locationName || location || `GPS (${latitude}, ${longitude})`;
    const newLog = {
        id: `log-${Date.now()}`,
        tripAssignmentId: trip.id,
        status: trip.status,
        location: locStr,
        latitude: latitude != null ? Number(latitude) : undefined,
        longitude: longitude != null ? Number(longitude) : undefined,
        speed: speed != null ? Number(speed) : undefined,
        locationName: locStr,
        notes: notes || 'GPS position recorded',
        timestamp: new Date().toISOString(),
    };
    const logs = store_1.store.trackingLogs.get(trip.id) || [];
    logs.push(newLog);
    store_1.store.trackingLogs.set(trip.id, logs);
    return res.status(201).json({
        success: true,
        message: 'Tracking log recorded successfully',
        data: newLog,
    });
}
async function getTripTrackingLogs(req, res) {
    await store_1.store.seedInitialData();
    const { id } = req.params;
    const trip = store_1.store.trips.get(id);
    if (!trip) {
        return res.status(404).json({ success: false, message: 'Trip assignment not found' });
    }
    const logs = store_1.store.trackingLogs.get(id) || [];
    return res.status(200).json({ success: true, count: logs.length, data: logs });
}
