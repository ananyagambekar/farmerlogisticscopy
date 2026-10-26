import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crop.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../models/vehicle.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'live_tracking_screen.dart';

class AgentDashboard extends StatefulWidget {
  const AgentDashboard({super.key});

  @override
  State<AgentDashboard> createState() => _AgentDashboardState();
}

class _AgentDashboardState extends State<AgentDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TransportBooking> _bookings = [];
  List<CropListing> _crops = [];
  List<User> _users = [];
  List<DriverVehicle> _vehicles = [];
  bool _loading = true;
  String _statusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token == null) return;

    setState(() => _loading = true);
    try {
      final bookings = await ApiService.getBookings(token);
      final crops = await ApiService.getCrops(token);
      final users = await ApiService.getUsers(token);
      final vehicles = await ApiService.getVehicles(token);

      setState(() {
        _bookings = bookings;
        _crops = crops;
        _users = users;
        _vehicles = vehicles;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Dispatch / Request Decision Dialog
  void _showDispatchDialog(TransportBooking booking) {
    // Filter drivers
    final drivers = _users.where((u) => u.role == UserRole.driver).toList();
    User? selectedDriver = drivers.isNotEmpty ? drivers.first : null;
    DriverVehicle? selectedVehicle = _vehicles.isNotEmpty ? _vehicles.first : null;
    final priceCtrl = TextEditingController(text: booking.estimatedCost.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Review Request: ${booking.id}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Requester: ${booking.requesterName ?? booking.requesterId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Route: ${booking.origin} ➔ ${booking.destination}'),
                        Text('Weight: ${booking.totalWeightKg} kg • Required Vehicle: ${booking.vehicleTypeRequired}'),
                        Text('Est. Price: KES ${booking.estimatedCost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                        Text('Current Status: ${booking.status}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Assign Logistics Dispatch:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<User>(
                    value: selectedDriver,
                    decoration: const InputDecoration(labelText: 'Assign Driver'),
                    items: drivers.map((d) {
                      return DropdownMenuItem(
                        value: d,
                        child: Text('${d.fullName} (${d.phone})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedDriver = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<DriverVehicle>(
                    value: selectedVehicle,
                    decoration: const InputDecoration(labelText: 'Assign Fleet Vehicle'),
                    items: _vehicles.map((v) {
                      return DropdownMenuItem(
                        value: v,
                        child: Text('${v.licensePlate} (${v.vehicleType} - ${v.capacityKg}kg)'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedVehicle = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Confirmed Trip Price (KES)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  final token = Provider.of<AuthService>(context, listen: false).token;
                  if (token != null) {
                    await ApiService.updateBookingStatus(token, booking.id, 'REJECTED');
                    if (mounted) {
                      Navigator.pop(ctx);
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Request Rejected')),
                      );
                    }
                  }
                },
                child: const Text('Reject Request'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final token = Provider.of<AuthService>(context, listen: false).token;
                  if (token != null && selectedDriver != null && selectedVehicle != null) {
                    final price = double.tryParse(priceCtrl.text) ?? booking.estimatedCost;
                    try {
                      await ApiService.assignBooking(
                        token,
                        booking.id,
                        driverId: selectedDriver!.id,
                        vehicleId: selectedVehicle!.id,
                        price: price,
                      );
                      if (mounted) {
                        Navigator.pop(ctx);
                        _loadData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Driver & Vehicle Dispatched Successfully!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  } else if (drivers.isEmpty || _vehicles.isEmpty) {
                    // Fallback accept without specific driver
                    await ApiService.updateBookingStatus(token!, booking.id, 'ACCEPTED');
                    if (mounted) {
                      Navigator.pop(ctx);
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Request Accepted!')),
                      );
                    }
                  }
                },
                child: const Text('Accept & Dispatch'),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
      case 'ACCEPTED':
      case 'ASSIGNED':
      case 'DELIVERED':
        return Colors.green;
      case 'RESERVED':
      case 'PENDING':
      case 'REQUESTED':
        return Colors.orange;
      case 'SOLD':
      case 'IN_TRANSIT':
        return Colors.blue;
      case 'CANCELLED':
      case 'REJECTED':
      case 'EXPIRED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    final pendingBookings = _bookings.where((b) => b.status == 'REQUESTED' || b.status == 'PENDING').toList();
    final filteredBookings = _statusFilter == 'ALL'
        ? _bookings
        : _bookings.where((b) => b.status.toUpperCase() == _statusFilter.toUpperCase()).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Aggregation Hub'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => auth.logout()),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: Badge(
                label: Text('${pendingBookings.length}'),
                isLabelVisible: pendingBookings.isNotEmpty,
                child: const Icon(Icons.mark_email_unread_outlined),
              ),
              text: 'Incoming Requests',
            ),
            const Tab(icon: Icon(Icons.eco), text: 'Public Produce'),
            const Tab(icon: Icon(Icons.local_shipping), text: 'Dispatch Board'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: INCOMING REQUESTS
          RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.blue.shade800,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.white24,
                            radius: 24,
                            child: Icon(Icons.hub_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.fullName ?? 'Agri Agent',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  '${pendingBookings.length} transport requests awaiting review & dispatch',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      const Text('Requests Pending Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${pendingBookings.length} items', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_loading)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  else if (pendingBookings.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('No pending transport requests.')),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingBookings.length,
                      itemBuilder: (ctx, idx) {
                        final b = pendingBookings[idx];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.between,
                                  children: [
                                    Text(
                                      'Farmer: ${b.requesterName ?? b.requesterId}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(b.status, style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 10)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Route: ${b.origin} ➔ ${b.destination}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text('Weight: ${b.totalWeightKg} kg • Required Vehicle: ${b.vehicleTypeRequired}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                const SizedBox(height: 6),
                                Text('Est. Tariff: KES ${b.estimatedCost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showDispatchDialog(b),
                                    icon: const Icon(Icons.assignment_turned_in),
                                    label: const Text('Review & Dispatch Driver'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // TAB 2: PUBLIC AVAILABLE CROPS
          RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available Public Produce Listings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  else if (_crops.isEmpty)
                    const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No produce listings found.'))))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _crops.length,
                      itemBuilder: (ctx, idx) {
                        final c = _crops[idx];
                        final color = _getStatusColor(c.status);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const CircleAvatar(backgroundColor: AppColors.lightGreen, child: Icon(Icons.eco, color: AppColors.primaryGreen)),
                            title: Text(c.cropType, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Farmer: ${c.farmerName ?? c.farmerId}\nQty: ${c.quantityKg} ${c.unit} • ${c.location}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('KES ${c.askingPricePerKg}/${c.unit}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Text(c.status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // TAB 3: DISPATCH BOARD / ALL BOOKINGS
          RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      const Text('All Transport Bookings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      DropdownButton<String>(
                        value: _statusFilter,
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('All Status')),
                          DropdownMenuItem(value: 'REQUESTED', child: Text('Requested')),
                          DropdownMenuItem(value: 'ASSIGNED', child: Text('Assigned')),
                          DropdownMenuItem(value: 'IN_TRANSIT', child: Text('In Transit')),
                          DropdownMenuItem(value: 'DELIVERED', child: Text('Delivered')),
                          DropdownMenuItem(value: 'REJECTED', child: Text('Rejected')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _statusFilter = v);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_loading)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  else if (filteredBookings.isEmpty)
                    const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No bookings match filter.'))))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredBookings.length,
                      itemBuilder: (ctx, idx) {
                        final b = filteredBookings[idx];
                        final statusColor = _getStatusColor(b.status);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text('${b.origin} ➔ ${b.destination}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Requester: ${b.requesterName ?? b.requesterId}'),
                                Text('Weight: ${b.totalWeightKg} kg • Vehicle: ${b.vehicleTypeRequired}'),
                                if (b.driverName != null)
                                  Text('Assigned Driver: ${b.driverName} (${b.vehiclePlate ?? 'Plate'})', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('KES ${b.estimatedCost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Text(b.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            onTap: () => _showDispatchDialog(b),
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
    );
  }
}
