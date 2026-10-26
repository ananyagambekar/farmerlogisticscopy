import { hashPassword } from '../utils/password';

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
  cropType: string; // or name
  quantityKg: number; // or quantity
  unit?: string; // 'kg', 'ton', 'bag', 'crate'
  askingPricePerKg: number; // or expectedPrice
  location: string; // or pickupLocation
  pickupLat?: number;
  pickupLng?: number;
  description?: string; // or notes
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
  origin: string; // or pickupLocation
  destination: string; // or destinationLocation
  totalWeightKg: number; // or estimatedWeight
  vehicleTypeRequired: string; // or requiredVehicleType
  estimatedCost: number; // or estimatedPrice
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

class InMemoryStore {
  public users: Map<string, UserRecord> = new Map();
  public crops: Map<string, CropListingRecord> = new Map();
  public bookings: Map<string, TransportBookingRecord> = new Map();
  public vehicles: Map<string, DriverVehicleRecord> = new Map();
  public trips: Map<string, TripAssignmentRecord> = new Map();
  public trackingLogs: Map<string, DeliveryStatusLogRecord[]> = new Map();
  public deliveryConfirmations: Map<string, DeliveryConfirmationRecord> = new Map();
  public configs: Map<string, SystemConfigRecord> = new Map();

  private initialized = false;

  public async seedInitialData() {
    if (this.initialized) return;
    const defaultPasswordHash = await hashPassword('Password123!');

    // Admin user
    const admin: UserRecord = {
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
    const farmer: UserRecord = {
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
    const agent: UserRecord = {
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
    const driver: UserRecord = {
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
    const receiver: UserRecord = {
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
    const crop1: CropListingRecord = {
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
    const crop2: CropListingRecord = {
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
    const vehicle1: DriverVehicleRecord = {
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
    const booking1: TransportBookingRecord = {
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
    const trip1: TripAssignmentRecord = {
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
    const logsTrip1: DeliveryStatusLogRecord[] = [
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
    const config1: SystemConfigRecord = {
      id: 'cfg-001',
      key: 'BASE_TRANSPORT_TARIFF_PER_KM',
      value: '15.5',
      description: 'Base pricing rate per km for transport calculations',
      updatedAt: new Date().toISOString(),
    };
    const config2: SystemConfigRecord = {
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

export const store = new InMemoryStore();
