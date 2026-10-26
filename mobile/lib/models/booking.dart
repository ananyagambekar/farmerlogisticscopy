class TransportBooking {
  final String id;
  final String requesterId;
  final String? requesterName;
  final String? cropListingId;
  final String? cropName;
  final String origin;
  final String destination;
  final String? targetDeliveryDate;
  final double totalWeightKg;
  final String vehicleTypeRequired;
  final double estimatedCost;
  final String status;
  final String? driverId;
  final String? driverName;
  final String? vehicleId;
  final String? vehiclePlate;

  TransportBooking({
    required this.id,
    required this.requesterId,
    this.requesterName,
    this.cropListingId,
    this.cropName,
    required this.origin,
    required this.destination,
    this.targetDeliveryDate,
    required this.totalWeightKg,
    required this.vehicleTypeRequired,
    required this.estimatedCost,
    required this.status,
    this.driverId,
    this.driverName,
    this.vehicleId,
    this.vehiclePlate,
  });

  factory TransportBooking.fromJson(Map<String, dynamic> json) {
    return TransportBooking(
      id: json['id'] ?? '',
      requesterId: json['requesterId'] ?? '',
      requesterName: json['requesterName'],
      cropListingId: json['cropListingId'],
      cropName: json['cropName'],
      origin: json['origin'] ?? json['pickupLocation'] ?? '',
      destination: json['destination'] ?? json['destinationLocation'] ?? '',
      targetDeliveryDate: json['targetDeliveryDate'],
      totalWeightKg: (json['totalWeightKg'] as num?)?.toDouble() ?? (json['estimatedWeight'] as num?)?.toDouble() ?? 0.0,
      vehicleTypeRequired: json['vehicleTypeRequired'] ?? json['requiredVehicleType'] ?? '',
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? (json['estimatedPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'REQUESTED',
      driverId: json['driverId'],
      driverName: json['driverName'],
      vehicleId: json['vehicleId'],
      vehiclePlate: json['vehiclePlate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'cropListingId': cropListingId,
      'cropName': cropName,
      'origin': origin,
      'destination': destination,
      'targetDeliveryDate': targetDeliveryDate,
      'totalWeightKg': totalWeightKg,
      'vehicleTypeRequired': vehicleTypeRequired,
      'estimatedCost': estimatedCost,
      'status': status,
      'driverId': driverId,
      'driverName': driverName,
      'vehicleId': vehicleId,
      'vehiclePlate': vehiclePlate,
    };
  }
}
