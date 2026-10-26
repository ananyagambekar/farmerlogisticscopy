import { User, CropListing, TransportBooking, TripAssignment, DriverVehicle, SystemConfig, DeliveryStatusLog, DeliveryConfirmation } from '../types';

const API_BASE = '/api/v1';

function getToken(): string | null {
  return localStorage.getItem('agri_token');
}

export function setToken(token: string) {
  localStorage.setItem('agri_token', token);
}

export function clearToken() {
  localStorage.removeItem('agri_token');
}

async function request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
  const token = getToken();
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string>),
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const response = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers,
  });

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.message || 'Request failed');
  }

  return data;
}

export const api = {
  login: (phone: string, password: string) =>
    request<{ success: boolean; data: { token: string; user: User } }>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ phone, password }),
    }),

  getMe: () =>
    request<{ success: boolean; data: User }>('/auth/me'),

  getUsers: () =>
    request<{ success: boolean; count: number; data: User[] }>('/users'),

  updateUserStatus: (id: string, isActive: boolean) =>
    request<{ success: boolean; data: User }>(`/users/${id}/status`, {
      method: 'PATCH',
      body: JSON.stringify({ isActive }),
    }),

  getCrops: (params?: { status?: string; search?: string; all?: boolean }) => {
    const q = new URLSearchParams();
    if (params?.status) q.append('status', params.status);
    if (params?.search) q.append('search', params.search);
    if (params?.all) q.append('all', 'true');
    const queryStr = q.toString() ? `?${q.toString()}` : '';
    return request<{ success: boolean; count: number; data: CropListing[] }>(`/crops${queryStr}`);
  },

  createCrop: (cropData: Partial<CropListing>) =>
    request<{ success: boolean; data: CropListing }>('/crops', {
      method: 'POST',
      body: JSON.stringify(cropData),
    }),

  updateCrop: (id: string, cropData: Partial<CropListing>) =>
    request<{ success: boolean; data: CropListing }>(`/crops/${id}`, {
      method: 'PUT',
      body: JSON.stringify(cropData),
    }),

  updateCropStatus: (id: string, status: string) =>
    request<{ success: boolean; data: CropListing }>(`/crops/${id}/status`, {
      method: 'PATCH',
      body: JSON.stringify({ status }),
    }),

  deleteCrop: (id: string) =>
    request<{ success: boolean; message: string }>(`/crops/${id}`, {
      method: 'DELETE',
    }),

  getBookings: (params?: { status?: string; all?: boolean }) => {
    const q = new URLSearchParams();
    if (params?.status) q.append('status', params.status);
    if (params?.all) q.append('all', 'true');
    const queryStr = q.toString() ? `?${q.toString()}` : '';
    return request<{ success: boolean; count: number; data: TransportBooking[] }>(`/bookings${queryStr}`);
  },

  createBooking: (bookingData: Partial<TransportBooking>) =>
    request<{ success: boolean; data: TransportBooking }>('/bookings', {
      method: 'POST',
      body: JSON.stringify(bookingData),
    }),

  estimateTransportCost: (data: {
    pickupLocation?: string;
    destinationLocation?: string;
    distanceKm?: number;
    estimatedWeight?: number;
    requiredVehicleType?: string;
  }) =>
    request<{
      success: boolean;
      estimatedPrice: number;
      distanceKm: number;
      breakdown: any;
    }>('/bookings/estimate', {
      method: 'POST',
      body: JSON.stringify(data),
    }),

  updateBookingStatus: (id: string, status: string) =>
    request<{ success: boolean; data: TransportBooking }>(`/bookings/${id}/status`, {
      method: 'PATCH',
      body: JSON.stringify({ status }),
    }),

  assignBooking: (id: string, payload: { driverId: string; vehicleId: string; price?: number }) =>
    request<{ success: boolean; data: { booking: TransportBooking; trip: TripAssignment } }>(`/bookings/${id}/assign`, {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  getTrips: () =>
    request<{ success: boolean; count: number; data: TripAssignment[] }>('/trips'),

  getTripById: (id: string) =>
    request<{ success: boolean; data: TripAssignment }>(`/trips/${id}`),

  updateTripStatus: (id: string, payload: { status: string; locationName?: string; notes?: string }) =>
    request<{ success: boolean; data: TripAssignment }>(`/trips/${id}/status`, {
      method: 'PATCH',
      body: JSON.stringify(payload),
    }),

  addTrackingLog: (id: string, payload: { latitude: number; longitude: number; speed?: number; locationName?: string; notes?: string }) =>
    request<{ success: boolean; data: DeliveryStatusLog }>(`/trips/${id}/tracking`, {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  getTripTrackingLogs: (id: string) =>
    request<{ success: boolean; count: number; data: DeliveryStatusLog[] }>(`/trips/${id}/tracking`),

  getIncomingDeliveries: () =>
    request<{ success: boolean; count: number; data: any[] }>('/deliveries/incoming'),

  confirmDelivery: (id: string, payload: { receivedQuantity: number; conditionRating: string; issueNotes?: string }) =>
    request<{ success: boolean; message: string; data: any }>(`/deliveries/${id}/confirm`, {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  getDeliveryHistory: () =>
    request<{ success: boolean; count: number; data: DeliveryConfirmation[] }>('/deliveries/history'),

  getVehicles: () =>
    request<{ success: boolean; count: number; data: DriverVehicle[] }>('/vehicles'),

  getSystemConfigs: () =>
    request<{ success: boolean; count: number; data: SystemConfig[] }>('/system-configs'),

  updateSystemConfig: (key: string, value: string, description?: string) =>
    request<{ success: boolean; data: SystemConfig }>(`/system-configs/${key}`, {
      method: 'PUT',
      body: JSON.stringify({ value, description }),
    }),
};
