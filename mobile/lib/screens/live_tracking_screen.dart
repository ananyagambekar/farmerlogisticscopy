import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String tripId;

  const LiveTrackingScreen({super.key, required this.tripId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  TripAssignment? _trip;
  List<DeliveryStatusLog> _logs = [];
  bool _isLoading = true;

  // Default Kenya Coordinates
  final LatLng _pickupCoord = const LatLng(-0.2833, 36.0667); // Nakuru
  final LatLng _destCoord = const LatLng(-1.286389, 36.817223); // Nairobi
  final LatLng _driverCoord = const LatLng(-0.7167, 36.4333); // En route near Naivasha

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    if (auth.token == null) return;

    setState(() => _isLoading = true);
    try {
      final trip = await ApiService.getTripDetail(auth.token!, widget.tripId);
      final logs = await ApiService.getTripTrackingLogs(auth.token!, widget.tripId);
      if (mounted) {
        setState(() {
          _trip = trip;
          _logs = logs;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading live tracking data: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _getStatusStepIndex(String status) {
    switch (status) {
      case 'ASSIGNED':
        return 0;
      case 'EN_ROUTE_PICKUP':
        return 1;
      case 'PICKED_UP':
      case 'AT_PICKUP':
        return 2;
      case 'IN_TRANSIT':
        return 3;
      case 'ARRIVED':
      case 'AT_DELIVERY':
        return 4;
      case 'DELIVERED':
      case 'COMPLETED':
        return 5;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    final currentStep = trip != null ? _getStatusStepIndex(trip.status) : 0;
    final progressRatio = (currentStep / 5).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Live Shipment Tracking #${widget.tripId}'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : trip == null
              ? const Center(child: Text('Trip assignment not found.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Progress Card
                      Card(
                        elevation: 3,
                        color: Colors.teal.shade900,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    trip.cropName ?? 'Cargo Shipment',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  Chip(
                                    label: Text(
                                      trip.status,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                    backgroundColor: Colors.teal.shade700,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progressRatio,
                                  minHeight: 10,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emerald),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${(progressRatio * 100).toStringAsFixed(0)}% Completed', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text('${(trip.totalWeightKg ?? 5000).toStringAsFixed(0)} kg', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Interactive Map Component
                      Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: SizedBox(
                          height: 220,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: _driverCoord,
                              initialZoom: 8.5,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.dynamicagrilogistics.farmer_logistics_mobile',
                              ),
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: [_pickupCoord, _driverCoord, _destCoord],
                                    strokeWidth: 4.0,
                                    color: AppColors.primaryGreen,
                                  ),
                                ],
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _pickupCoord,
                                    width: 36,
                                    height: 36,
                                    child: const Icon(Icons.location_on, color: Colors.green, size: 36),
                                  ),
                                  Marker(
                                    point: _driverCoord,
                                    width: 40,
                                    height: 40,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade800,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(Icons.local_shipping, color: Colors.white, size: 22),
                                    ),
                                  ),
                                  Marker(
                                    point: _destCoord,
                                    width: 36,
                                    height: 36,
                                    child: const Icon(Icons.flag, color: Colors.red, size: 36),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Driver & Vehicle Card
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.lightGreen,
                                child: Icon(Icons.person, color: AppColors.primaryGreen, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(trip.driverName ?? 'Assigned Driver', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 2),
                                    Text('Vehicle: ${trip.vehiclePlate ?? "N/A"} • ${trip.vehicleType ?? "Truck"}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                    if (trip.driverPhone != null)
                                      Text('Phone: ${trip.driverPhone}', style: const TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              if (trip.driverPhone != null)
                                IconButton(
                                  icon: const Icon(Icons.phone, color: AppColors.primaryGreen),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Calling Driver at ${trip.driverPhone}...')),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Origin and Destination Card
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.my_location, color: Colors.green),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Pickup Origin', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                        Text(trip.origin ?? 'Nakuru North Farm', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 11),
                                child: SizedBox(height: 16, child: VerticalDivider(thickness: 2, color: Colors.grey)),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.red),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Delivery Destination', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                        Text(trip.destination ?? 'Nairobi Fresh Produce Hub', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Latest GPS Tracking Timeline
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Live Tracking Log History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const Divider(),
                              _logs.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Text('No tracking updates logged yet.', style: TextStyle(color: AppColors.textMuted)),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _logs.length,
                                      separatorBuilder: (_, __) => const Divider(height: 12),
                                      itemBuilder: (ctx, idx) {
                                        final log = _logs[_logs.length - 1 - idx];
                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: const CircleAvatar(
                                            radius: 12,
                                            backgroundColor: AppColors.lightGreen,
                                            child: Icon(Icons.gps_fixed, size: 14, color: AppColors.primaryGreen),
                                          ),
                                          title: Text(log.status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          subtitle: Text('${log.location} ${log.notes != null ? "• " + log.notes! : ""}', style: const TextStyle(fontSize: 12)),
                                          trailing: Text(
                                            log.timestamp.length >= 16 ? log.timestamp.substring(11, 16) : log.timestamp,
                                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
    );
  }
}
