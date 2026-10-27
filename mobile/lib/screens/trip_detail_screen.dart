import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class TripDetailScreen extends StatefulWidget {
  final TripAssignment trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late TripAssignment _currentTrip;
  List<DeliveryStatusLog> _logs = [];
  bool _isLoading = false;
  bool _isGpsSharingEnabled = true;

  final LatLng _pickupCoord = const LatLng(-0.2833, 36.0667);
  final LatLng _destCoord = const LatLng(-1.286389, 36.817223);
  final LatLng _driverCoord = const LatLng(-0.7167, 36.4333);

  final List<String> _statusSequence = [
    'ASSIGNED',
    'EN_ROUTE_PICKUP',
    'PICKED_UP',
    'IN_TRANSIT',
    'ARRIVED',
    'DELIVERED',
  ];

  @override
  void initState() {
    super.initState();
    _currentTrip = widget.trip;
    _logs = widget.trip.deliveryStatusLogs;
    _refreshTripDetails();
  }

  Future<void> _refreshTripDetails() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    if (auth.token == null) return;

    setState(() => _isLoading = true);
    try {
      final updated = await ApiService.getTripDetail(auth.token!, _currentTrip.id);
      final logs = await ApiService.getTripTrackingLogs(auth.token!, _currentTrip.id);
      if (mounted) {
        setState(() {
          _currentTrip = updated;
          _logs = logs;
        });
      }
    } catch (e) {
      // Fallback
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getNextStatus(String currentStatus) {
    int idx = _statusSequence.indexOf(currentStatus);
    if (idx >= 0 && idx < _statusSequence.length - 1) {
      return _statusSequence[idx + 1];
    }
    return currentStatus;
  }

  Future<void> _handleStatusUpdate(String newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Status Update'),
        content: Text('Are you sure you want to transition trip status to "$newStatus"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final auth = Provider.of<AuthService>(context, listen: false);
    if (auth.token == null) return;

    setState(() => _isLoading = true);
    try {
      final updated = await ApiService.updateTripStatus(
        auth.token!,
        _currentTrip.id,
        newStatus,
        locationName: _currentTrip.origin ?? 'Active Route Location',
        notes: 'Driver updated status to $newStatus',
      );
      if (mounted) {
        setState(() => _currentTrip = updated);
        _refreshTripDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e'), backgroundColor: Colors.red),
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
    final nextStatus = _getNextStatus(_currentTrip.status);
    final canAdvance = nextStatus != _currentTrip.status;
    final currentStep = _getStatusStepIndex(_currentTrip.status);

    return Scaffold(
      appBar: AppBar(
        title: Text('Trip #${_currentTrip.id} Console'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshTripDetails),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Timeline Header Card
                  Card(
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
                                _currentTrip.cropName ?? 'Agricultural Freight',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Chip(
                                label: Text(
                                  _currentTrip.status,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                                backgroundColor: _getStatusColor(_currentTrip.status),
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              _buildProgressStep(0, 'Assigned', currentStep),
                              _buildStepConnector(0, currentStep),
                              _buildProgressStep(1, 'En Route', currentStep),
                              _buildStepConnector(1, currentStep),
                              _buildProgressStep(2, 'Pickup', currentStep),
                              _buildStepConnector(2, currentStep),
                              _buildProgressStep(3, 'Transit', currentStep),
                              _buildStepConnector(3, currentStep),
                              _buildProgressStep(4, 'Arrived', currentStep),
                              _buildStepConnector(4, currentStep),
                              _buildProgressStep(5, 'Delivered', currentStep),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Route Visualizer Map
                  _buildRouteMapWidget(),

                  const SizedBox(height: 16),

                  // Action Button for Driver Status Progression
                  if (canAdvance)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                        label: Text(
                          'Advance Trip Status to "$nextStatus"',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _handleStatusUpdate(nextStatus),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Live Location Consent Toggle
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.gps_fixed, color: AppColors.primaryGreen),
                                  SizedBox(width: 8),
                                  Text('Live GPS Location Consent', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Switch(
                                value: _isGpsSharingEnabled,
                                activeThumbColor: AppColors.primaryGreen,
                                onChanged: (val) {
                                  setState(() {
                                    _isGpsSharingEnabled = val;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Location updates are shared strictly during active transit for shipment security and farmer visibility.',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Details Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cargo & Route Specifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.my_location, color: Colors.green),
                            title: const Text('Pickup Point (Origin)'),
                            subtitle: Text(_currentTrip.origin ?? 'Nakuru North Farm'),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.location_on, color: Colors.red),
                            title: const Text('Delivery Point (Destination)'),
                            subtitle: Text(_currentTrip.destination ?? 'Nairobi Produce Hub'),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.scale, color: Colors.blue),
                            title: const Text('Total Cargo Weight'),
                            subtitle: Text('${(_currentTrip.totalWeightKg ?? 5000).toStringAsFixed(0)} kg'),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.attach_money, color: Colors.amber),
                            title: const Text('Driver Fare Compensation'),
                            subtitle: Text('KES ${_currentTrip.price.toStringAsFixed(0)}'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Audit Log
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('GPS Checkpoint Logs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('${_logs.length} logged', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                          const Divider(),
                          _logs.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text('No tracking checkpoint logs recorded yet.', style: TextStyle(color: AppColors.textMuted)),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _logs.length,
                                  separatorBuilder: (_, __) => const Divider(height: 16),
                                  itemBuilder: (ctx, idx) {
                                    final log = _logs[_logs.length - 1 - idx];
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor: _getStatusColor(log.status).withValues(alpha: 0.2),
                                          child: Icon(
                                            log.status == 'DELIVERED'
                                                ? Icons.check_circle
                                                : log.status == 'IN_TRANSIT'
                                                    ? Icons.local_shipping
                                                    : Icons.location_on,
                                            size: 16,
                                            color: _getStatusColor(log.status),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(log.status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                  Text(
                                                    log.timestamp.length >= 16 ? log.timestamp.substring(11, 16) : log.timestamp,
                                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(log.location, style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
                                              if (log.notes != null && log.notes!.isNotEmpty)
                                                Text(log.notes!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                            ],
                                          ),
                                        ),
                                      ],
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

  Widget _buildRouteMapWidget() {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 200,
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
                  width: 32,
                  height: 32,
                  child: const Icon(Icons.location_on, color: Colors.green, size: 32),
                ),
                Marker(
                  point: _driverCoord,
                  width: 36,
                  height: 36,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.local_shipping, color: Colors.white, size: 20),
                  ),
                ),
                Marker(
                  point: _destCoord,
                  width: 32,
                  height: 32,
                  child: const Icon(Icons.flag, color: Colors.red, size: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(int index, String label, int currentStep) {
    final isDone = index <= currentStep;
    final isCurrent = index == currentStep;

    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isCurrent
              ? AppColors.primaryGreen
              : isDone
                  ? Colors.green.shade700
                  : Colors.grey.shade300,
          child: Icon(
            isDone ? Icons.check : Icons.circle,
            size: 12,
            color: isDone || isCurrent ? Colors.white : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isDone ? AppColors.textDark : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int index, int currentStep) {
    final isDone = index < currentStep;
    return Expanded(
      child: Container(
        height: 2,
        color: isDone ? AppColors.primaryGreen : Colors.grey.shade300,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ASSIGNED':
        return Colors.blue;
      case 'EN_ROUTE_PICKUP':
      case 'AT_PICKUP':
        return Colors.orange;
      case 'PICKED_UP':
      case 'IN_TRANSIT':
        return Colors.purple;
      case 'ARRIVED':
      case 'AT_DELIVERY':
        return Colors.teal;
      case 'DELIVERED':
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
