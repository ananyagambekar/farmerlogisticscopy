class DeliveryStatusLog {
  final String id;
  final String tripAssignmentId;
  final String status;
  final String location;
  final double? latitude;
  final double? longitude;
  final double? speed;
  final String? locationName;
  final String? notes;
  final String timestamp;

  DeliveryStatusLog({
    required this.id,
    required this.tripAssignmentId,
    required this.status,
    required this.location,
    this.latitude,
    this.longitude,
    this.speed,
    this.locationName,
    this.notes,
    required this.timestamp,
  });

  factory DeliveryStatusLog.fromJson(Map<String, dynamic> json) {
    return DeliveryStatusLog(
      id: json['id'] ?? '',
      tripAssignmentId: json['tripAssignmentId'] ?? '',
      status: json['status'] ?? '',
      location: json['location'] ?? json['locationName'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      locationName: json['locationName'],
      notes: json['notes'],
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripAssignmentId': tripAssignmentId,
      'status': status,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'locationName': locationName,
      'notes': notes,
      'timestamp': timestamp,
    };
  }
}

class DeliveryConfirmation {
  final String id;
  final String tripId;
  final String bookingId;
  final String receiverId;
  final String? receiverName;
  final double receivedQuantity;
  final String conditionRating; // EXCELLENT | GOOD | ACCEPTABLE | DAMAGED
  final String? issueNotes;
  final String confirmedAt;
  final String? cropName;
  final String? driverName;
  final String? vehiclePlate;
  final String? origin;
  final String? destination;
  final double? expectedQuantityKg;

  DeliveryConfirmation({
    required this.id,
    required this.tripId,
    required this.bookingId,
    required this.receiverId,
    this.receiverName,
    required this.receivedQuantity,
    required this.conditionRating,
    this.issueNotes,
    required this.confirmedAt,
    this.cropName,
    this.driverName,
    this.vehiclePlate,
    this.origin,
    this.destination,
    this.expectedQuantityKg,
  });

  factory DeliveryConfirmation.fromJson(Map<String, dynamic> json) {
    return DeliveryConfirmation(
      id: json['id'] ?? '',
      tripId: json['tripId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      receiverName: json['receiverName'],
      receivedQuantity: (json['receivedQuantity'] as num?)?.toDouble() ?? 0.0,
      conditionRating: json['conditionRating'] ?? 'GOOD',
      issueNotes: json['issueNotes'],
      confirmedAt: json['confirmedAt'] ?? '',
      cropName: json['cropName'],
      driverName: json['driverName'],
      vehiclePlate: json['vehiclePlate'],
      origin: json['origin'],
      destination: json['destination'],
      expectedQuantityKg: (json['expectedQuantityKg'] as num?)?.toDouble(),
    );
  }
}

class TripAssignment {
  final String id;
  final String bookingId;
  final String driverId;
  final String? driverName;
  final String? driverPhone;
  final String vehicleId;
  final String? vehiclePlate;
  final String? vehicleType;
  final String status;
  final double price;
  final String assignedAt;
  final String? startedAt;
  final String? completedAt;
  final String? cropName;
  final double? totalWeightKg;
  final String? origin;
  final String? destination;
  final List<DeliveryStatusLog> deliveryStatusLogs;
  final DeliveryStatusLog? latestLog;

  TripAssignment({
    required this.id,
    required this.bookingId,
    required this.driverId,
    this.driverName,
    this.driverPhone,
    required this.vehicleId,
    this.vehiclePlate,
    this.vehicleType,
    required this.status,
    required this.price,
    required this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.cropName,
    this.totalWeightKg,
    this.origin,
    this.destination,
    this.deliveryStatusLogs = const [],
    this.latestLog,
  });

  factory TripAssignment.fromJson(Map<String, dynamic> json) {
    final booking = json['booking'] as Map<String, dynamic>?;
    final crop = booking?['crop'] as Map<String, dynamic>?;
    final driver = json['driver'] as Map<String, dynamic>?;
    final vehicle = json['vehicle'] as Map<String, dynamic>?;

    final logsRaw = json['deliveryStatusLogs'] as List?;
    final logsList = logsRaw != null
        ? logsRaw.map((e) => DeliveryStatusLog.fromJson(e)).toList()
        : <DeliveryStatusLog>[];

    DeliveryStatusLog? latest;
    if (json['latestLog'] != null) {
      latest = DeliveryStatusLog.fromJson(json['latestLog']);
    } else if (logsList.isNotEmpty) {
      latest = logsList.last;
    }

    return TripAssignment(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      driverId: json['driverId'] ?? '',
      driverName: driver?['fullName'] ?? json['driverName'],
      driverPhone: driver?['phone'],
      vehicleId: json['vehicleId'] ?? '',
      vehiclePlate: vehicle?['licensePlate'] ?? json['vehiclePlate'],
      vehicleType: vehicle?['vehicleType'],
      status: json['status'] ?? 'ASSIGNED',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      assignedAt: json['assignedAt'] ?? '',
      startedAt: json['startedAt'],
      completedAt: json['completedAt'],
      cropName: crop?['cropType'] ?? booking?['cropName'] ?? json['cropName'],
      totalWeightKg: (booking?['totalWeightKg'] as num?)?.toDouble() ?? (crop?['quantityKg'] as num?)?.toDouble() ?? (json['totalWeightKg'] as num?)?.toDouble(),
      origin: booking?['origin'] ?? crop?['location'] ?? json['origin'],
      destination: booking?['destination'] ?? json['destination'],
      deliveryStatusLogs: logsList,
      latestLog: latest,
    );
  }
}
