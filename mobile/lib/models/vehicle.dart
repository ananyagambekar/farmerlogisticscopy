class DriverVehicle {
  final String id;
  final String driverId;
  final String? driverName;
  final String vehicleType;
  final double capacityKg;
  final String licensePlate;
  final String status;

  DriverVehicle({
    required this.id,
    required this.driverId,
    this.driverName,
    required this.vehicleType,
    required this.capacityKg,
    required this.licensePlate,
    required this.status,
  });

  factory DriverVehicle.fromJson(Map<String, dynamic> json) {
    return DriverVehicle(
      id: json['id'] ?? '',
      driverId: json['driverId'] ?? '',
      driverName: json['driverName'],
      vehicleType: json['vehicleType'] ?? '',
      capacityKg: (json['capacityKg'] as num?)?.toDouble() ?? 0.0,
      licensePlate: json['licensePlate'] ?? '',
      status: json['status'] ?? 'IDLE',
    );
  }
}
