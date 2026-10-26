import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'trip_detail_screen.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  String _vehicleStatus = 'IDLE';
  List<TripAssignment> _assignedTrips = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAssignedTrips();
  }

  Future<void> _fetchAssignedTrips() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    if (auth.token == null) return;

    setState(() => _isLoading = true);
    try {
      final trips = await ApiService.getAssignedTrips(auth.token!);
      setState(() {
        _assignedTrips = trips;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading trips: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver & Fleet Console'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAssignedTrips),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => auth.logout()),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Profile Card
            Card(
              color: Colors.amber.shade800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white24,
                      radius: 26,
                      child: Icon(Icons.local_shipping, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Driver David Ochieng',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Vehicle Plate: KCF 789X (10-Ton Refrigerated Truck)',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Vehicle Status Toggle
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Vehicle Availability Status', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Current Status: $_vehicleStatus', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                    Switch(
                      value: _vehicleStatus == 'IN_TRANSIT',
                      activeColor: AppColors.primaryGreen,
                      onChanged: (val) {
                        setState(() {
                          _vehicleStatus = val ? 'IN_TRANSIT' : 'IDLE';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                const Text('Assigned Dispatch Trips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${_assignedTrips.length} active', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),

            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                : _assignedTrips.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('No trip assignments found.', style: TextStyle(color: AppColors.textMuted))),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _assignedTrips.length,
                        itemBuilder: (ctx, idx) {
                          final trip = _assignedTrips[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip)),
                                );
                                _fetchAssignedTrips();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.between,
                                      children: [
                                        Text(
                                          'TRIP #${trip.id}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 14),
                                        ),
                                        Chip(
                                          label: Text(
                                            trip.status,
                                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                          backgroundColor: _getStatusColor(trip.status),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    Row(
                                      children: [
                                        const Icon(Icons.eco, color: Colors.green, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Cargo: ${trip.cropName ?? "Agricultural Crop"} (${(trip.totalWeightKg ?? 5000).toStringAsFixed(0)} kg)',
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.alt_route, color: Colors.blue, size: 16),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '${trip.origin ?? "Origin"} ➔ ${trip.destination ?? "Destination"}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textDark),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.between,
                                      children: [
                                        Text(
                                          'Compensation: KES ${trip.price.toStringAsFixed(0)}',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                        ),
                                        const Row(
                                          children: [
                                            Text('Open Tracker', style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                                            Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primaryGreen),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
