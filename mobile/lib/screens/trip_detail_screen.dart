import 'package:flutter/material.dart';
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
  bool _gpsConsentGiven = true;

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
      setState(() {
        _currentTrip = updated;
        _logs = logs;
      });
    } catch (e) {
      // Fallback to local state if offline or network error
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
        title: Text('Confirm Status Update'),
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
      final updatedLogs = await ApiService.getTripTrackingLogs(auth.token!, _currentTrip.id);
      setState(() {
        _currentTrip = updated;
        _logs = updatedLogs;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status successfully updated to $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showManualLocationDialog() async {
    final locationController = TextEditingController();
    final latController = TextEditingController(text: '-0.2833');
    final lngController = TextEditingController(text: '36.0667');
    final speedController = TextEditingController(text: '50');
    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manual GPS Location Entry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location Name / Landmark',
                  hintText: 'e.g. Naivasha Highway Junction',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: latController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: const InputDecoration(labelText: 'Latitude'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: lngController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: const InputDecoration(labelText: 'Longitude'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: speedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Current Speed (km/h)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = Provider.of<AuthService>(context, listen: false);
              if (auth.token == null) return;

              final locName = locationController.text.trim().isNotEmpty
                  ? locationController.text.trim()
                  : 'Manual Checkpoint';
              final lat = double.tryParse(latController.text) ?? -0.2833;
              final lng = double.tryParse(lngController.text) ?? 36.0667;
              final speed = double.tryParse(speedController.text) ?? 0.0;
              final notes = notesController.text.trim();

              setState(() => _isLoading = true);
              try {
                await ApiService.sendTrackingLog(
                  auth.token!,
                  _currentTrip.id,
                  latitude: lat,
                  longitude: lng,
                  speed: speed,
                  locationName: locName,
                  notes: notes.isNotEmpty ? notes : 'Manual GPS check-in',
                );
                await _refreshTripDetails();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Manual location log recorded!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error recording location: $e'), backgroundColor: Colors.red),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            child: const Text('Save Checkpoint'),
          ),
        ],
      ),
    );
  }

  void _toggleGpsConsent(bool value) {
    if (value && !_gpsConsentGiven) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('GPS Sharing User Consent'),
          content: const Text(
            'By enabling GPS Sharing, you consent to broadcasting your real-time vehicle location to the shipment requester and destination receiving hub for delivery tracking.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isGpsSharingEnabled = false;
                  _gpsConsentGiven = false;
                });
              },
              child: const Text('Decline'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isGpsSharingEnabled = true;
                  _gpsConsentGiven = true;
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              child: const Text('I Agree'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _isGpsSharingEnabled = value;
      });
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
    final currentStep = _getStatusStepIndex(_currentTrip.status);
    final nextStatus = _getNextStatus(_currentTrip.status);
    final isFinished = _currentTrip.status == 'DELIVERED' || _currentTrip.status == 'COMPLETED';

    return Scaffold(
      appBar: AppBar(
        title: Text('Trip #${_currentTrip.id} Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTripDetails,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Summary Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.between,
                            children: [
                              Text(
                                _currentTrip.cropName ?? 'Agricultural Produce Cargo',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
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
                          const SizedBox(height: 8),
                          Text(
                            'Cargo Weight: ${(_currentTrip.totalWeightKg ?? 5000).toStringAsFixed(0)} kg',
                            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                          ),
                          Text(
                            'Freight Compensation: KES ${_currentTrip.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.my_location, color: Colors.green, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text('Origin: ${_currentTrip.origin ?? "Pickup Location"}', style: const TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.red, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text('Destination: ${_currentTrip.destination ?? "Delivery Hub"}', style: const TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Route Map Visualization Widget
                  _buildRouteMapWidget(),

                  const SizedBox(height: 16),

                  // Visual Progress Tracker
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Trip Status Progression', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildProgressStep(0, 'Assigned', currentStep),
                              _buildStepConnector(0, currentStep),
                              _buildProgressStep(1, 'En-Route', currentStep),
                              _buildStepConnector(1, currentStep),
                              _buildProgressStep(2, 'Picked Up', currentStep),
                              _buildStepConnector(2, currentStep),
                              _buildProgressStep(3, 'In Transit', currentStep),
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

                  // One-tap Action Progression Button
                  if (!isFinished)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.navigation, color: Colors.white),
                        label: Text(
                          'Advance Trip Status to "$nextStatus"',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
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

                  // GPS Sharing & Manual Checkpoint Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Real-time GPS Location Sharing', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              _isGpsSharingEnabled
                                  ? 'Brdcasting live GPS coordinates to operations board'
                                  : 'GPS sharing disabled (Fallback mode active)',
                              style: const TextStyle(fontSize: 12),
                            ),
                            activeColor: AppColors.primaryGreen,
                            value: _isGpsSharingEnabled,
                            onChanged: _toggleGpsConsent,
                          ),
                          const Divider(),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.edit_location_alt, color: AppColors.primaryGreen),
                            label: const Text('Manual Location Checkpoint (Fallback)', style: TextStyle(color: AppColors.primaryGreen)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryGreen),
                              minimumSize: const Size.fromHeight(42),
                            ),
                            onPressed: _showManualLocationDialog,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tracking History Timeline Logs
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.between,
                            children: [
                              const Text('Delivery Status Log Stream', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('${_logs.length} checkpoints', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                          const Divider(),
                          _logs.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(child: Text('No tracking logs recorded yet.', style: TextStyle(color: AppColors.textMuted))),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _logs.length,
                                  separatorBuilder: (_, __) => const Divider(height: 16),
                                  itemBuilder: (ctx, idx) {
                                    final log = _logs[_logs.length - 1 - idx]; // reversed timeline
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor: _getStatusColor(log.status).withOpacity(0.2),
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
                                                mainAxisAlignment: MainAxisAlignment.between,
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
                                              if (log.speed != null)
                                                Text('Speed: ${log.speed!.toStringAsFixed(0)} km/h', style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
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
    final progressStep = _getStatusStepIndex(_currentTrip.status);
    final progressRatio = (progressStep / 5).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Slate dark map background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.slate.shade700),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              const Row(
                children: [
                  Icon(Icons.map, color: Colors.emerald, size: 18),
                  SizedBox(width: 6),
                  Text('Route Visualizer & Live GPS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.emerald.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: Text(
                  '${(progressRatio * 100).toStringAsFixed(0)}% Completed',
                  style: const TextStyle(color: Colors.emeraldAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Visual Route Path Line
          Stack(
            children: [
              // Background line
              Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.slate.shade700, borderRadius: BorderRadius.circular(2)),
              ),
              // Active line
              FractionallySizedBox(
                widthFactor: progressRatio,
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.emerald, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              // Nodes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMapPinNode(Icons.nature_people, 'Pickup', Colors.green),
                  _buildMapPinNode(Icons.local_shipping, 'Driver GPS', progressStep > 0 && progressStep < 5 ? Colors.amber : Colors.blueGrey),
                  _buildMapPinNode(Icons.warehouse, 'Delivery', Colors.redAccent),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            _currentTrip.latestLog?.location != null
                ? 'Current Location: ${_currentTrip.latestLog!.location}'
                : 'Current Location: ${_currentTrip.origin ?? "In Route"}',
            style: const TextStyle(color: Colors.slate300, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPinNode(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.slate400, fontSize: 10)),
      ],
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
