import { Response } from 'express';
import { store, DriverVehicleRecord } from '../services/store';
import { AuthenticatedRequest } from '../middleware/auth';

export async function getVehicles(req: AuthenticatedRequest, res: Response) {
  await store.seedInitialData();
  const list = Array.from(store.vehicles.values());
  return res.status(200).json({ success: true, count: list.length, data: list });
}

export async function registerVehicle(req: AuthenticatedRequest, res: Response) {
  await store.seedInitialData();
  const { vehicleType, capacityKg, licensePlate } = req.body;

  if (!vehicleType || !capacityKg || !licensePlate) {
    return res.status(400).json({ success: false, message: 'vehicleType, capacityKg, licensePlate are required' });
  }

  const driverId = req.user?.userId || 'usr-driver-001';
  const driver = store.users.get(driverId);

  const newVehicle: DriverVehicleRecord = {
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

  store.vehicles.set(newVehicle.id, newVehicle);
  return res.status(201).json({ success: true, message: 'Vehicle registered', data: newVehicle });
}

export async function updateVehicleStatus(req: AuthenticatedRequest, res: Response) {
  await store.seedInitialData();
  const { id } = req.params;
  const { status } = req.body;
  const vehicle = store.vehicles.get(id);

  if (!vehicle) {
    return res.status(404).json({ success: false, message: 'Vehicle not found' });
  }

  vehicle.status = status;
  vehicle.updatedAt = new Date().toISOString();
  store.vehicles.set(id, vehicle);

  return res.status(200).json({ success: true, message: 'Vehicle status updated', data: vehicle });
}
