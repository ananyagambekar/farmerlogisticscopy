"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getIncomingDeliveries = getIncomingDeliveries;
exports.confirmDelivery = confirmDelivery;
exports.getDeliveryHistory = getDeliveryHistory;
const store_1 = require("../services/store");
async function getIncomingDeliveries(req, res) {
    await store_1.store.seedInitialData();
    // Retrieve incoming trips that are assigned, en-route, in transit, or arrived
    const allTrips = Array.from(store_1.store.trips.values());
    const activeTrips = allTrips.filter((t) => ['ASSIGNED', 'EN_ROUTE_PICKUP', 'PICKED_UP', 'AT_PICKUP', 'IN_TRANSIT', 'ARRIVED', 'AT_DELIVERY'].includes(t.status));
    const data = activeTrips.map((trip) => {
        const booking = store_1.store.bookings.get(trip.bookingId);
        const crop = booking?.cropListingId ? store_1.store.crops.get(booking.cropListingId) : undefined;
        const driver = store_1.store.users.get(trip.driverId);
        const vehicle = store_1.store.vehicles.get(trip.vehicleId);
        return {
            id: trip.id,
            tripId: trip.id,
            bookingId: trip.bookingId,
            status: trip.status,
            cropName: crop?.cropType || booking?.cropName || 'Farm Produce',
            totalWeightKg: booking?.totalWeightKg || crop?.quantityKg || 0,
            origin: booking?.origin || crop?.location || 'Origin Farm',
            destination: booking?.destination || 'Nairobi Central Receiving Hub',
            eta: '15-30 mins',
            driverName: driver?.fullName || trip.driverName || 'Driver',
            driverPhone: driver?.phone || '+254700000003',
            vehiclePlate: vehicle?.licensePlate || trip.vehiclePlate || 'KCF 789X',
            vehicleType: vehicle?.vehicleType || 'Transport Truck',
            assignedAt: trip.assignedAt,
            startedAt: trip.startedAt,
        };
    });
    return res.status(200).json({ success: true, count: data.length, data });
}
async function confirmDelivery(req, res) {
    await store_1.store.seedInitialData();
    const { id } = req.params; // tripId or deliveryId
    const { receivedQuantity, conditionRating, issueNotes } = req.body;
    if (!receivedQuantity || !conditionRating) {
        return res.status(400).json({
            success: false,
            message: 'receivedQuantity and conditionRating are required',
        });
    }
    const validRatings = ['EXCELLENT', 'GOOD', 'ACCEPTABLE', 'DAMAGED'];
    if (!validRatings.includes(conditionRating)) {
        return res.status(400).json({
            success: false,
            message: `Invalid conditionRating. Must be one of: ${validRatings.join(', ')}`,
        });
    }
    // Find trip by id or matching bookingId
    let trip = store_1.store.trips.get(id);
    if (!trip) {
        const matchedTrip = Array.from(store_1.store.trips.values()).find((t) => t.id === id || t.bookingId === id);
        if (matchedTrip)
            trip = matchedTrip;
    }
    if (!trip) {
        return res.status(404).json({ success: false, message: 'Trip or shipment assignment not found' });
    }
    const receiverId = req.user?.userId || 'usr-receiver-001';
    const receiverUser = store_1.store.users.get(receiverId);
    // Update Trip status to DELIVERED
    trip.status = 'DELIVERED';
    trip.completedAt = new Date().toISOString();
    trip.updatedAt = new Date().toISOString();
    store_1.store.trips.set(trip.id, trip);
    // Update Booking status to DELIVERED
    const booking = store_1.store.bookings.get(trip.bookingId);
    if (booking) {
        booking.status = 'DELIVERED';
        booking.updatedAt = new Date().toISOString();
        store_1.store.bookings.set(booking.id, booking);
        // Update Crop Listing status to SOLD
        if (booking.cropListingId) {
            const crop = store_1.store.crops.get(booking.cropListingId);
            if (crop) {
                crop.status = 'SOLD';
                crop.updatedAt = new Date().toISOString();
                store_1.store.crops.set(crop.id, crop);
            }
        }
    }
    // Create DeliveryConfirmation record
    const confirmationRecord = {
        id: `conf-${Date.now()}`,
        tripId: trip.id,
        bookingId: trip.bookingId,
        receiverId,
        receiverName: receiverUser?.fullName || 'Receiver Hub Manager',
        receivedQuantity: Number(receivedQuantity),
        conditionRating,
        issueNotes: issueNotes || undefined,
        confirmedAt: new Date().toISOString(),
    };
    store_1.store.deliveryConfirmations.set(confirmationRecord.id, confirmationRecord);
    // Append DELIVERED log entry to tracking logs
    const deliveredLog = {
        id: `log-${Date.now()}`,
        tripAssignmentId: trip.id,
        status: 'DELIVERED',
        location: booking?.destination || 'Receiver Warehouse Hub',
        notes: `Delivery confirmed by receiver. Quantity: ${receivedQuantity}kg, Condition: ${conditionRating}. ${issueNotes ? 'Notes: ' + issueNotes : ''}`,
        timestamp: new Date().toISOString(),
    };
    const logs = store_1.store.trackingLogs.get(trip.id) || [];
    logs.push(deliveredLog);
    store_1.store.trackingLogs.set(trip.id, logs);
    return res.status(200).json({
        success: true,
        message: 'Delivery receipt confirmed successfully',
        data: {
            confirmation: confirmationRecord,
            trip,
            booking,
        },
    });
}
async function getDeliveryHistory(req, res) {
    await store_1.store.seedInitialData();
    const list = Array.from(store_1.store.deliveryConfirmations.values());
    const enrichedHistory = list.map((conf) => {
        const trip = store_1.store.trips.get(conf.tripId);
        const booking = store_1.store.bookings.get(conf.bookingId);
        const crop = booking?.cropListingId ? store_1.store.crops.get(booking.cropListingId) : undefined;
        const driver = trip ? store_1.store.users.get(trip.driverId) : undefined;
        return {
            ...conf,
            cropName: crop?.cropType || booking?.cropName || 'Farm Produce',
            driverName: driver?.fullName || trip?.driverName || 'Driver',
            vehiclePlate: trip?.vehiclePlate || 'KCF 789X',
            origin: booking?.origin || 'Origin',
            destination: booking?.destination || 'Destination',
            expectedQuantityKg: booking?.totalWeightKg || crop?.quantityKg || 0,
        };
    });
    return res.status(200).json({ success: true, count: enrichedHistory.length, data: enrichedHistory });
}
