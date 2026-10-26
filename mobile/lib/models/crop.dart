class CropListing {
  final String id;
  final String farmerId;
  final String? farmerName;
  final String cropType;
  final double quantityKg;
  final String unit;
  final double askingPricePerKg;
  final String location;
  final double? pickupLat;
  final double? pickupLng;
  final String? description;
  final String status;
  final String harvestDate;

  CropListing({
    required this.id,
    required this.farmerId,
    this.farmerName,
    required this.cropType,
    required this.quantityKg,
    this.unit = 'kg',
    required this.askingPricePerKg,
    required this.location,
    this.pickupLat,
    this.pickupLng,
    this.description,
    required this.status,
    required this.harvestDate,
  });

  factory CropListing.fromJson(Map<String, dynamic> json) {
    return CropListing(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'],
      cropType: json['cropType'] ?? json['name'] ?? '',
      quantityKg: (json['quantityKg'] as num?)?.toDouble() ?? (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'kg',
      askingPricePerKg: (json['askingPricePerKg'] as num?)?.toDouble() ?? (json['expectedPrice'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] ?? json['pickupLocation'] ?? '',
      pickupLat: (json['pickupLat'] as num?)?.toDouble(),
      pickupLng: (json['pickupLng'] as num?)?.toDouble(),
      description: json['description'] ?? json['notes'],
      status: json['status'] ?? 'AVAILABLE',
      harvestDate: json['harvestDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'cropType': cropType,
      'quantityKg': quantityKg,
      'unit': unit,
      'askingPricePerKg': askingPricePerKg,
      'location': location,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'description': description,
      'status': status,
      'harvestDate': harvestDate,
    };
  }
}
