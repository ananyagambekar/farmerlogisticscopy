import 'package:flutter_test/flutter_test.dart';
import 'package:farmer_logistics_mobile/models/user.dart';
import 'package:farmer_logistics_mobile/models/crop.dart';
import 'package:farmer_logistics_mobile/models/booking.dart';
import 'package:farmer_logistics_mobile/models/trip.dart';

void main() {
  test('UserRole enum serialization & deserialization works', () {
    expect(UserRoleExtension.fromString('FARMER'), UserRole.farmer);
    expect(UserRoleExtension.fromString('AGENT'), UserRole.agent);
    expect(UserRoleExtension.fromString('DRIVER'), UserRole.driver);
    expect(UserRoleExtension.fromString('RECEIVER'), UserRole.receiver);
    expect(UserRoleExtension.fromString('ADMIN'), UserRole.admin);

    expect(UserRole.farmer.toShortString(), 'FARMER');
    expect(UserRole.agent.toShortString(), 'AGENT');
    expect(UserRole.driver.toShortString(), 'DRIVER');
    expect(UserRole.receiver.toShortString(), 'RECEIVER');
    expect(UserRole.admin.toShortString(), 'ADMIN');
  });

  test('User model deserializes correctly', () {
    final json = {
      'id': 'usr-001',
      'phone': '+254700000001',
      'fullName': 'Test Farmer',
      'role': 'FARMER',
      'isActive': true,
      'createdAt': '2026-01-01T00:00:00Z',
    };

    final user = User.fromJson(json);
    expect(user.id, 'usr-001');
    expect(user.phone, '+254700000001');
    expect(user.role, UserRole.farmer);
  });

  test('CropListing model deserializes & serializes correctly', () {
    final json = {
      'id': 'crop-101',
      'farmerId': 'usr-farmer-001',
      'farmerName': 'John Farmer',
      'cropType': 'Maize (Grade A)',
      'quantityKg': 5000.0,
      'unit': 'kg',
      'askingPricePerKg': 45.0,
      'location': 'Nakuru North Farm',
      'description': 'Fresh harvest',
      'status': 'AVAILABLE',
      'harvestDate': '2026-10-26T10:00:00Z',
    };

    final crop = CropListing.fromJson(json);
    expect(crop.id, 'crop-101');
    expect(crop.cropType, 'Maize (Grade A)');
    expect(crop.quantityKg, 5000.0);
    expect(crop.unit, 'kg');
    expect(crop.askingPricePerKg, 45.0);
    expect(crop.status, 'AVAILABLE');

    final backToJson = crop.toJson();
    expect(backToJson['id'], 'crop-101');
    expect(backToJson['cropType'], 'Maize (Grade A)');
  });

  test('TransportBooking model deserializes & serializes correctly', () {
    final json = {
      'id': 'bk-101',
      'requesterId': 'usr-farmer-001',
      'requesterName': 'John Farmer',
      'cropListingId': 'crop-101',
      'origin': 'Nakuru Farm',
      'destination': 'Nairobi Market',
      'totalWeightKg': 5000.0,
      'vehicleTypeRequired': '10-Ton Truck',
      'estimatedCost': 25000.0,
      'status': 'REQUESTED',
    };

    final booking = TransportBooking.fromJson(json);
    expect(booking.id, 'bk-101');
    expect(booking.origin, 'Nakuru Farm');
    expect(booking.destination, 'Nairobi Market');
    expect(booking.totalWeightKg, 5000.0);
    expect(booking.vehicleTypeRequired, '10-Ton Truck');
    expect(booking.estimatedCost, 25000.0);
    expect(booking.status, 'REQUESTED');
  });

  test('TripAssignment and DeliveryStatusLog deserialize correctly', () {
    final json = {
      'id': 'trip-001',
      'bookingId': 'bk-001',
      'driverId': 'usr-driver-001',
      'driverName': 'David Ochieng',
      'vehicleId': 'veh-001',
      'vehiclePlate': 'KCF 789X',
      'status': 'IN_TRANSIT',
      'price': 25000.0,
      'assignedAt': '2026-10-26T10:00:00Z',
      'cropName': 'Maize (Grade A)',
      'totalWeightKg': 5000.0,
      'origin': 'Nakuru North Farm',
      'destination': 'Nairobi Fresh Produce Hub',
      'deliveryStatusLogs': [
        {
          'id': 'log-001',
          'tripAssignmentId': 'trip-001',
          'status': 'IN_TRANSIT',
          'location': 'Naivasha Highway',
          'latitude': -0.7167,
          'longitude': 36.4333,
          'speed': 65.0,
          'timestamp': '2026-10-26T11:00:00Z',
        }
      ],
    };

    final trip = TripAssignment.fromJson(json);
    expect(trip.id, 'trip-001');
    expect(trip.driverName, 'David Ochieng');
    expect(trip.vehiclePlate, 'KCF 789X');
    expect(trip.status, 'IN_TRANSIT');
    expect(trip.price, 25000.0);
    expect(trip.deliveryStatusLogs.length, 1);
    expect(trip.deliveryStatusLogs.first.location, 'Naivasha Highway');
    expect(trip.deliveryStatusLogs.first.speed, 65.0);
  });

  test('DeliveryConfirmation model deserializes correctly', () {
    final json = {
      'id': 'conf-001',
      'tripId': 'trip-001',
      'bookingId': 'bk-001',
      'receiverId': 'usr-receiver-001',
      'receiverName': 'Nairobi Produce Hub',
      'receivedQuantity': 4980.0,
      'conditionRating': 'EXCELLENT',
      'issueNotes': '20kg slight weight loss due to drying in transit',
      'confirmedAt': '2026-10-26T14:00:00Z',
      'cropName': 'Maize (Grade A)',
    };

    final conf = DeliveryConfirmation.fromJson(json);
    expect(conf.id, 'conf-001');
    expect(conf.receivedQuantity, 4980.0);
    expect(conf.conditionRating, 'EXCELLENT');
    expect(conf.issueNotes, contains('20kg'));
  });
}
