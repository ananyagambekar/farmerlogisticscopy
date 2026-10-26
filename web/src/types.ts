export type Role = 'FARMER' | 'AGENT' | 'DRIVER' | 'RECEIVER' | 'ADMIN';

export interface User {
  id: string;
  phone: string;
  email?: string;
  fullName: string;
  role: Role;
  isActive: boolean;
  createdAt: string;
}

export interface CropListing {
  id: string;
  farmerId: string;
  farmerName?: string;
  cropType: string;
  quantityKg: number;
  unit?: string;
  askingPricePerKg: number;
  location: string;
  pickupLat?: number;
  pickupLng?: number;
  description?: string;
  status: 'AVAILABLE' | 'RESERVED' | 'SOLD' | 'CANCELLED' | 'EXPIRED';
  harvestDate: string;
  createdAt: string;
}

export interface TransportBooking {
  id: string;
  requesterId: string;
  requesterName?: string;
  cropListingId?: string;
  cropName?: string;
  origin: string;
  destination: string;
  targetDeliveryDate?: string;
  totalWeightKg: number;
  vehicleTypeRequired: string;
  estimatedCost: number;
  status: 'PENDING' | 'REQUESTED' | 'ACCEPTED' | 'ASSIGNED' | 'MATCHED' | 'IN_TRANSIT' | 'DELIVERED' | 'REJECTED' | 'CANCELLED';
  driverId?: string;
  driverName?: string;
  vehicleId?: string;
  vehiclePlate?: string;
  createdAt: string;
}

export interface DriverVehicle {
  id: string;
  driverId: string;
  driverName?: string;
  vehicleType: string;
  capacityKg: number;
  licensePlate: string;
  status: 'IDLE' | 'IN_TRANSIT' | 'MAINTENANCE' | 'INACTIVE';
  createdAt: string;
}

export interface DeliveryStatusLog {
  id: string;
  tripAssignmentId: string;
  status: string;
  location: string;
  latitude?: number;
  longitude?: number;
  speed?: number;
  locationName?: string;
  notes?: string;
  timestamp: string;
}

export interface DeliveryConfirmation {
  id: string;
  tripId: string;
  bookingId: string;
  receiverId: string;
  receiverName?: string;
  receivedQuantity: number;
  conditionRating: 'EXCELLENT' | 'GOOD' | 'ACCEPTABLE' | 'DAMAGED';
  issueNotes?: string;
  confirmedAt: string;
  cropName?: string;
  driverName?: string;
  vehiclePlate?: string;
  origin?: string;
  destination?: string;
  expectedQuantityKg?: number;
}

export interface TripAssignment {
  id: string;
  bookingId: string;
  driverId: string;
  driverName?: string;
  driverPhone?: string;
  vehicleId: string;
  vehiclePlate?: string;
  vehicleType?: string;
  status: 'ASSIGNED' | 'EN_ROUTE_PICKUP' | 'PICKED_UP' | 'AT_PICKUP' | 'IN_TRANSIT' | 'ARRIVED' | 'AT_DELIVERY' | 'DELIVERED' | 'COMPLETED' | 'CANCELLED';
  price: number;
  assignedAt: string;
  startedAt?: string;
  completedAt?: string;
  cropName?: string;
  totalWeightKg?: number;
  origin?: string;
  destination?: string;
  booking?: TransportBooking;
  deliveryStatusLogs?: DeliveryStatusLog[];
  latestLog?: DeliveryStatusLog;
}

export interface SystemConfig {
  id: string;
  key: string;
  value: string;
  description?: string;
  updatedAt: string;
}
