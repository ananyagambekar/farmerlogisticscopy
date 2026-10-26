export interface UserRecord {
    id: string;
    phone: string;
    email?: string;
    password: string;
    fullName: string;
    role: 'FARMER' | 'AGENT' | 'DRIVER' | 'RECEIVER' | 'ADMIN';
    isActive: boolean;
    createdAt: string;
    updatedAt: string;
}
export interface CropListingRecord {
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
    isDeleted?: boolean;
    createdAt: string;
    updatedAt: string;
}
export interface TransportBookingRecord {
    id: string;
    requesterId: string;
    requesterName?: string;
    cropListingId?: string;
    cropName?: string;
    origin: string;
    destination: string;
    totalWeightKg: number;
    vehicleTypeRequired: string;
    estimatedCost: number;
    targetDeliveryDate?: string;
    status: 'PENDING' | 'REQUESTED' | 'ACCEPTED' | 'ASSIGNED' | 'MATCHED' | 'IN_TRANSIT' | 'DELIVERED' | 'REJECTED' | 'CANCELLED';
    driverId?: string;
    driverName?: string;
    vehicleId?: string;
    vehiclePlate?: string;
    createdAt: string;
    updatedAt: string;
}
export interface DriverVehicleRecord {
    id: string;
    driverId: string;
    driverName?: string;
    vehicleType: string;
    capacityKg: number;
    licensePlate: string;
    status: 'IDLE' | 'IN_TRANSIT' | 'MAINTENANCE' | 'INACTIVE';
    createdAt: string;
    updatedAt: string;
}
export interface TripAssignmentRecord {
    id: string;
    bookingId: string;
    driverId: string;
    driverName?: string;
    vehicleId: string;
    vehiclePlate?: string;
    status: 'ASSIGNED' | 'EN_ROUTE_PICKUP' | 'PICKED_UP' | 'AT_PICKUP' | 'IN_TRANSIT' | 'ARRIVED' | 'AT_DELIVERY' | 'DELIVERED' | 'COMPLETED' | 'CANCELLED';
    price: number;
    assignedAt: string;
    startedAt?: string;
    completedAt?: string;
    createdAt: string;
    updatedAt: string;
}
export interface DeliveryStatusLogRecord {
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
export interface DeliveryConfirmationRecord {
    id: string;
    tripId: string;
    bookingId: string;
    receiverId: string;
    receiverName?: string;
    receivedQuantity: number;
    conditionRating: 'EXCELLENT' | 'GOOD' | 'ACCEPTABLE' | 'DAMAGED';
    issueNotes?: string;
    confirmedAt: string;
}
export interface SystemConfigRecord {
    id: string;
    key: string;
    value: string;
    description?: string;
    updatedAt: string;
}
declare class InMemoryStore {
    users: Map<string, UserRecord>;
    crops: Map<string, CropListingRecord>;
    bookings: Map<string, TransportBookingRecord>;
    vehicles: Map<string, DriverVehicleRecord>;
    trips: Map<string, TripAssignmentRecord>;
    trackingLogs: Map<string, DeliveryStatusLogRecord[]>;
    deliveryConfirmations: Map<string, DeliveryConfirmationRecord>;
    configs: Map<string, SystemConfigRecord>;
    private initialized;
    seedInitialData(): Promise<void>;
}
export declare const store: InMemoryStore;
export {};
