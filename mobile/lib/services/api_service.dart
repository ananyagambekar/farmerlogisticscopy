import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/crop.dart';
import '../models/booking.dart';
import '../models/trip.dart';
import '../models/vehicle.dart';

class ApiService {
  // 10.0.2.2 for Android Emulator, localhost for local test or device IP
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  static Map<String, String> _headers(String? token) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static String normalizePhone(String phone) {
    String cleaned = phone.trim().replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleaned.startsWith('+')) {
      if (cleaned.startsWith('0')) {
        cleaned = '+254${cleaned.substring(1)}';
      } else {
        cleaned = '+$cleaned';
      }
    }
    return cleaned;
  }

  static Future<double> calculatePricingEstimate({
    required double weightKg,
    required String vehicleType,
    required String origin,
    required String destination,
  }) async {
    // Distance rule or tariff calculation
    double baseRate = 5000.0; // base transport charge
    double distanceKm = 120.0; // estimated default distance between locations
    double weightFactor = (weightKg / 1000.0) * 1500.0;
    double vehicleMultiplier = vehicleType.contains('Refrigerated') ? 1.3 : 1.0;

    double calculated = (baseRate + (distanceKm * 50) + weightFactor) * vehicleMultiplier;
    return calculated.clamp(3000.0, 150000.0);
  }

  static Future<Map<String, dynamic>> login(String phone, String password) async {
    final normalized = normalizePhone(phone);
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(null),
      body: jsonEncode({'phone': normalized, 'password': password}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return body['data'];
    } else {
      throw Exception(body['message'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String phone,
    String? email,
    required String password,
    required UserRole role,
  }) async {
    final normalized = normalizePhone(phone);
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers(null),
      body: jsonEncode({
        'fullName': fullName,
        'phone': normalized,
        'email': email,
        'password': password,
        'role': role.toShortString(),
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 201 && body['success'] == true) {
      return body['data'];
    } else {
      throw Exception(body['message'] ?? 'Registration failed');
    }
  }

  static Future<User> getMe(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers(token),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return User.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to load user profile');
    }
  }

  static Future<List<User>> getUsers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: _headers(token),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      final List list = body['data'] ?? [];
      return list.map((e) => User.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<CropListing>> getCrops(String token, {String? status, String? search}) async {
    String query = '';
    final params = <String>[];
    if (status != null && status.isNotEmpty) params.add('status=$status');
    if (search != null && search.isNotEmpty) params.add('search=${Uri.encodeComponent(search)}');
    if (params.isNotEmpty) query = '?${params.join('&')}';

    final response = await http.get(
      Uri.parse('$baseUrl/crops$query'),
      headers: _headers(token),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      final List list = body['data'] ?? [];
      return list.map((e) => CropListing.fromJson(e)).toList();
    }
    return [];
  }

  static Future<CropListing> createCrop(String token, Map<String, dynamic> cropData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/crops'),
      headers: _headers(token),
      body: jsonEncode(cropData),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 201 && body['success'] == true) {
      return CropListing.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to create crop listing');
    }
  }

  static Future<CropListing> updateCrop(String token, String id, Map<String, dynamic> cropData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/crops/$id'),
      headers: _headers(token),
      body: jsonEncode(cropData),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return CropListing.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to update crop listing');
    }
  }

  static Future<void> deleteCrop(String token, String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/crops/$id'),
      headers: _headers(token),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to delete crop listing');
    }
  }

  static Future<List<TransportBooking>> getBookings(String token, {String? status}) async {
    String query = '';
    if (status != null && status.isNotEmpty) {
      query = '?status=$status';
    }

    final response = await http.get(
      Uri.parse('$baseUrl/bookings$query'),
      headers: _headers(token),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      final List list = body['data'] ?? [];
      return list.map((e) => TransportBooking.fromJson(e)).toList();
    }
    return [];
  }

  static Future<TransportBooking> createBooking(String token, Map<String, dynamic> bookingData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: _headers(token),
      body: jsonEncode(bookingData),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 201 && body['success'] == true) {
      return TransportBooking.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to create transport booking');
    }
  }

  static Future<double> estimateTransportCost(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/estimate'),
      headers: _headers(token),
      body: jsonEncode(data),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return (body['estimatedPrice'] as num?)?.toDouble() ?? (body['estimatedCost'] as num?)?.toDouble() ?? 0.0;
    } else {
      throw Exception(body['message'] ?? 'Failed to calculate transport estimate');
    }
  }

  static Future<TransportBooking> updateBookingStatus(String token, String id, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/bookings/$id/status'),
      headers: _headers(token),
      body: jsonEncode({'status': status}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return TransportBooking.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to update booking status');
    }
  }

  static Future<Map<String, dynamic>> assignBooking(
    String token,
    String id, {
    required String driverId,
    required String vehicleId,
    double? price,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/$id/assign'),
      headers: _headers(token),
      body: jsonEncode({
        'driverId': driverId,
        'vehicleId': vehicleId,
        if (price != null) 'price': price,
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return body['data'];
    } else {
      throw Exception(body['message'] ?? 'Failed to assign driver and vehicle');
    }
  }

  static Future<List<TripAssignment>> getTrips(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/trips'),
      headers: _headers(token),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      final List list = body['data'] ?? [];
      return list.map((e) => TripAssignment.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<TripAssignment>> getAssignedTrips(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/trips/assigned'),
      headers: _headers(token),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      final List list = body['data'] ?? [];
      return list.map((e) => TripAssignment.fromJson(e)).toList();
    }
    return [];
  }

  static Future<TripAssignment> getTripDetail(String token, String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/trips/$id'),
      headers: _headers(token),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return TripAssignment.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to fetch trip details');
    }
  }

  static Future<TripAssignment> updateTripStatus(
    String token,
    String id,
    String status, {
    String? locationName,
    double? latitude,
    double? longitude,
    double? speed,
    String? notes,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/trips/$id/status'),
      headers: _headers(token),
      body: jsonEncode({
        'status': status,
        if (locationName != null) 'locationName': locationName,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (speed != null) 'speed': speed,
        if (notes != null) 'notes': notes,
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return TripAssignment.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to update trip status');
    }
  }

  static Future<DeliveryStatusLog> sendTrackingLog(
    String token,
    String id, {
    required double latitude,
    required double longitude,
    double? speed,
    String? locationName,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/trips/$id/tracking'),
      headers: _headers(token),
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        if (speed != null) 'speed': speed,
        if (locationName != null) 'locationName': locationName,
        if (notes != null) 'notes': notes,
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 201 && body['success'] == true) {
      return DeliveryStatusLog.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to post tracking log');
    }
  }

  static Future<List<DeliveryStatusLog>> getTripTrackingLogs(String token, String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/trips/$id/tracking'),
      headers: _headers(token),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      final List list = body['data'] ?? [];
      return list.map((e) => DeliveryStatusLog.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getIncomingDeliveries(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/deliveries/incoming'),
      headers: _headers(token),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      final List list = body['data'] ?? [];
      return list.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<Map<String, dynamic>> confirmDelivery(
    String token,
    String id, {
    required double receivedQuantity,
    required String conditionRating,
    String? issueNotes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/deliveries/$id/confirm'),
      headers: _headers(token),
      body: jsonEncode({
        'receivedQuantity': receivedQuantity,
        'conditionRating': conditionRating,
        if (issueNotes != null && issueNotes.isNotEmpty) 'issueNotes': issueNotes,
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return body['data'];
    } else {
      throw Exception(body['message'] ?? 'Failed to confirm delivery');
    }
  }

  static Future<List<DeliveryConfirmation>> getDeliveryHistory(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/deliveries/history'),
      headers: _headers(token),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      final List list = body['data'] ?? [];
      return list.map((e) => DeliveryConfirmation.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<DriverVehicle>> getVehicles(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/vehicles'),
      headers: _headers(token),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      final List list = body['data'] ?? [];
      return list.map((e) => DriverVehicle.fromJson(e)).toList();
    }
    return [];
  }
}
