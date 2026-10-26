"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getBookings = getBookings;
exports.createBooking = createBooking;
exports.estimateBookingCost = estimateBookingCost;
exports.updateBookingStatus = updateBookingStatus;
exports.assignBooking = assignBooking;
const store_1 = require("../services/store");
async function getBookings(req, res) {
    await store_1.store.seedInitialData();
    let list = Array.from(store_1.store.bookings.values());
    const user = req.user;
    const { status, all } = req.query;
    // Role-based filtering:
    // Farmer sees created bookings
    // Agent sees incoming requests to review
    // Admin sees all
    if (user?.role === 'FARMER' && all !== 'true') {
        list = list.filter(b => b.requesterId === user.userId);
    }
    else if (user?.role === 'DRIVER') {
        list = list.filter(b => b.driverId === user.userId || b.status === 'ASSIGNED' || b.status === 'MATCHED' || b.status === 'IN_TRANSIT');
    }
    // Filter by status if query parameter provided
    if (status && typeof status === 'string') {
        const targetStatus = status.toUpperCase();
        list = list.filter(b => b.status.toUpperCase() === targetStatus);
    }
    return res.status(200).json({ success: true, count: list.length, data: list });
}
async function createBooking(req, res) {
    await store_1.store.seedInitialData();
    const { cropListingId, pickupLocation, origin, destinationLocation, destination, targetDeliveryDate, requiredVehicleType, vehicleTypeRequired, estimatedWeight, totalWeightKg, estimatedPrice, estimatedCost, } = req.body;
    const finalOrigin = pickupLocation || origin;
    const finalDest = destinationLocation || destination;
    const finalWeight = Number(estimatedWeight ?? totalWeightKg);
    const finalVehicle = requiredVehicleType || vehicleTypeRequired;
    const finalPrice = Number(estimatedPrice ?? estimatedCost ?? 10000);
    if (!finalOrigin || !finalDest || isNaN(finalWeight) || finalWeight <= 0 || !finalVehicle) {
        return res.status(400).json({
            success: false,
            message: 'pickupLocation/origin, destinationLocation/destination, estimatedWeight/totalWeightKg (>0), and requiredVehicleType/vehicleTypeRequired are required',
        });
    }
    const requesterId = req.user?.userId || 'usr-farmer-001';
    const requester = store_1.store.users.get(requesterId);
    let cropName;
    if (cropListingId) {
        const crop = store_1.store.crops.get(cropListingId);
        if (crop) {
            cropName = crop.cropType;
        }
    }
    const newBooking = {
        id: `bk-${Date.now()}`,
        requesterId,
        requesterName: requester?.fullName || 'Requester',
        cropListingId,
        cropName,
        origin: finalOrigin,
        destination: finalDest,
        totalWeightKg: finalWeight,
        vehicleTypeRequired: finalVehicle,
        estimatedCost: finalPrice,
        targetDeliveryDate: targetDeliveryDate || new Date(Date.now() + 86400000).toISOString(),
        status: 'REQUESTED',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
    };
    store_1.store.bookings.set(newBooking.id, newBooking);
    return res.status(201).json({ success: true, message: 'Transport booking created successfully', data: newBooking });
}
async function estimateBookingCost(req, res) {
    await store_1.store.seedInitialData();
    const { pickupLocation, origin, destinationLocation, destination, distanceKm, quantity, estimatedWeight, totalWeightKg, requiredVehicleType, vehicleType, } = req.body;
    const weight = Number(estimatedWeight ?? totalWeightKg ?? quantity ?? 1000);
    const vType = String(requiredVehicleType || vehicleType || '3-TON').toUpperCase();
    const dist = Number(distanceKm || 50);
    let multiplier = 1.3;
    if (vType.includes('PICKUP'))
        multiplier = 1.0;
    else if (vType.includes('3-TON') || vType.includes('3 TON'))
        multiplier = 1.5;
    else if (vType.includes('10-TON') || vType.includes('10 TON'))
        multiplier = 2.2;
    else if (vType.includes('REFRIGERATED') || vType.includes('COLD'))
        multiplier = 2.8;
    const baseRatePerKm = 25;
    const weightFee = Math.round(weight * 1.5);
    const distanceCost = Math.round(dist * baseRatePerKm * multiplier);
    const estimatedTotal = distanceCost + weightFee;
    return res.status(200).json({
        success: true,
        estimatedPrice: estimatedTotal,
        estimatedCost: estimatedTotal,
        distanceKm: dist,
        weightKg: weight,
        vehicleType: vType,
        breakdown: {
            baseRatePerKm,
            distanceKm: dist,
            vehicleMultiplier: multiplier,
            distanceCost,
            weightFee,
            total: estimatedTotal,
        },
    });
}
async function updateBookingStatus(req, res) {
    await store_1.store.seedInitialData();
    const { id } = req.params;
    const { status } = req.body;
    const booking = store_1.store.bookings.get(id);
    if (!booking) {
        return res.status(404).json({ success: false, message: 'Transport booking not found' });
    }
    if (status) {
        const sUpper = status.toUpperCase();
        booking.status = sUpper;
        booking.updatedAt = new Date().toISOString();
        store_1.store.bookings.set(id, booking);
    }
    return res.status(200).json({ success: true, message: `Booking status updated to ${booking.status}`, data: booking });
}
async function assignBooking(req, res) {
    await store_1.store.seedInitialData();
    const { id } = req.params;
    const { driverId, vehicleId, price } = req.body;
    const booking = store_1.store.bookings.get(id);
    if (!booking) {
        return res.status(404).json({ success: false, message: 'Booking not found' });
    }
    // Find driver or default driver
    let driver = driverId ? store_1.store.users.get(driverId) : undefined;
    if (!driver) {
        driver = Array.from(store_1.store.users.values()).find(u => u.role === 'DRIVER') || store_1.store.users.get('usr-driver-001');
    }
    // Find vehicle or default vehicle
    let vehicle = vehicleId ? store_1.store.vehicles.get(vehicleId) : undefined;
    if (!vehicle) {
        vehicle = Array.from(store_1.store.vehicles.values()).find(v => v.status === 'IDLE') || Array.from(store_1.store.vehicles.values())[0];
    }
    const assignedPrice = Number(price || booking.estimatedCost);
    const newTrip = {
        id: `trip-${Date.now()}`,
        bookingId: booking.id,
        driverId: driver?.id || driverId || 'usr-driver-001',
        driverName: driver?.fullName || 'Assigned Driver',
        vehicleId: vehicle?.id || vehicleId || 'veh-001',
        vehiclePlate: vehicle?.licensePlate || 'KCF 789X',
        status: 'ASSIGNED',
        price: assignedPrice,
        assignedAt: new Date().toISOString(),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
    };
    store_1.store.trips.set(newTrip.id, newTrip);
    // Update booking details and status
    booking.status = 'ASSIGNED';
    booking.driverId = newTrip.driverId;
    booking.driverName = newTrip.driverName;
    booking.vehicleId = newTrip.vehicleId;
    booking.vehiclePlate = newTrip.vehiclePlate;
    booking.updatedAt = new Date().toISOString();
    store_1.store.bookings.set(id, booking);
    // Update vehicle status
    if (vehicle) {
        vehicle.status = 'IN_TRANSIT';
        vehicle.updatedAt = new Date().toISOString();
        store_1.store.vehicles.set(vehicle.id, vehicle);
    }
    return res.status(200).json({
        success: true,
        message: 'Driver and vehicle assigned successfully',
        data: {
            booking,
            trip: newTrip,
        },
    });
}
