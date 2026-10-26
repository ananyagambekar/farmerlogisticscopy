"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getVehicles = getVehicles;
exports.registerVehicle = registerVehicle;
exports.updateVehicleStatus = updateVehicleStatus;
const store_1 = require("../services/store");
async function getVehicles(req, res) {
    await store_1.store.seedInitialData();
    const list = Array.from(store_1.store.vehicles.values());
    return res.status(200).json({ success: true, count: list.length, data: list });
}
async function registerVehicle(req, res) {
    await store_1.store.seedInitialData();
    const { vehicleType, capacityKg, licensePlate } = req.body;
    if (!vehicleType || !capacityKg || !licensePlate) {
        return res.status(400).json({ success: false, message: 'vehicleType, capacityKg, licensePlate are required' });
    }
    const driverId = req.user?.userId || 'usr-driver-001';
    const driver = store_1.store.users.get(driverId);
    const newVehicle = {
        id: `veh-${Date.now()}`,
        driverId,
        driverName: driver?.fullName || 'Driver',
        vehicleType,
        capacityKg: Number(capacityKg),
        licensePlate: licensePlate.toUpperCase().trim(),
        status: 'IDLE',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
    };
    store_1.store.vehicles.set(newVehicle.id, newVehicle);
    return res.status(201).json({ success: true, message: 'Vehicle registered', data: newVehicle });
}
async function updateVehicleStatus(req, res) {
    await store_1.store.seedInitialData();
    const { id } = req.params;
    const { status } = req.body;
    const vehicle = store_1.store.vehicles.get(id);
    if (!vehicle) {
        return res.status(404).json({ success: false, message: 'Vehicle not found' });
    }
    vehicle.status = status;
    vehicle.updatedAt = new Date().toISOString();
    store_1.store.vehicles.set(id, vehicle);
    return res.status(200).json({ success: true, message: 'Vehicle status updated', data: vehicle });
}
