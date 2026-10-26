import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'delivery_confirmation_modal.dart';

class ReceiverDashboard extends StatefulWidget {
  const ReceiverDashboard({super.key});

  @override
  State<ReceiverDashboard> createState() => _ReceiverDashboardState();
}

class _ReceiverDashboardState extends State<ReceiverDashboard> {
  List<Map<String, dynamic>> _incomingShipments = [];
  List<DeliveryConfirmation> _historyLogs = [];
  bool _isLoading = false;

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
      final incoming = await ApiService.getIncomingDeliveries(auth.token!);
      final history = await ApiService.getDeliveryHistory(auth.token!);
      setState(() {
        _incomingShipments = incoming;
        _historyLogs = history;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading shipments: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openConfirmationModal(Map<String, dynamic> delivery) {
    showDialog(
      context: context,
      builder: (ctx) => DeliveryConfirmationModal(
        delivery: delivery,
        onConfirmed: _loadData,
      ),
    );
  }

  Color _getRatingColor(String rating) {
    switch (rating) {
      case 'EXCELLENT':
        return Colors.green;
      case 'GOOD':
        return Colors.teal;
      case 'ACCEPTABLE':
        return Colors.orange;
      case 'DAMAGED':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Receiver & Warehouse Log'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.local_shipping), text: 'Incoming Shipments'),
              Tab(icon: Icon(Icons.history_edu), text: 'Verified Delivery Log'),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
            IconButton(icon: const Icon(Icons.logout), onPressed: () => auth.logout()),
          ],
        ),
        body: Column(
          children: [
            // Header Profile Banner
            Container(
              color: Colors.teal.shade800,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white24,
                    radius: 24,
                    child: Icon(Icons.store, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'Nairobi Fresh Produce Hub',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Text(
                          'Warehouse Destination: Nairobi Central Receiving Hub',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : TabBarView(
                      children: [
                        // Tab 1: Incoming Shipments
                        RefreshIndicator(
                          onRefresh: _loadData,
                          child: _incomingShipments.isEmpty
                              ? const Center(child: Text('No active incoming produce shipments.', style: TextStyle(color: AppColors.textMuted)))
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _incomingShipments.length,
                                  itemBuilder: (ctx, idx) {
                                    final item = _incomingShipments[idx];
                                    final cropName = item['cropName'] ?? 'Farm Produce';
                                    final weight = (item['totalWeightKg'] as num?)?.toDouble() ?? 5000.0;
                                    final driver = item['driverName'] ?? 'David Ochieng';
                                    final plate = item['vehiclePlate'] ?? 'KCF 789X';
                                    final status = item['status'] ?? 'IN_TRANSIT';
                                    final eta = item['eta'] ?? '15-30 mins';

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.between,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${weight.toStringAsFixed(0)} kg $cropName',
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                                                  ),
                                                ),
                                                Chip(
                                                  label: Text(status, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                                  backgroundColor: Colors.purple,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text('Driver: $driver • Reg: $plate', style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                                            Text('Estimated Arrival: $eta', style: const TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                                            Text('Origin: ${item["origin"]}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                            const SizedBox(height: 12),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                                                label: const Text('Verify & Receive Shipment', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.primaryGreen,
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                onPressed: () => _openConfirmationModal(item),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),

                        // Tab 2: Historical Verified Delivery Log
                        RefreshIndicator(
                          onRefresh: _loadData,
                          child: _historyLogs.isEmpty
                              ? const Center(child: Text('No verified delivery history recorded yet.', style: TextStyle(color: AppColors.textMuted)))
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _historyLogs.length,
                                  itemBuilder: (ctx, idx) {
                                    final conf = _historyLogs[_historyLogs.length - 1 - idx];
                                    final color = _getRatingColor(conf.conditionRating);

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
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
                                                  conf.cropName ?? 'Verified Shipment',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                ),
                                                Chip(
                                                  label: Text(
                                                    conf.conditionRating,
                                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                  ),
                                                  backgroundColor: color,
                                                ),
                                              ],
                                            ),
                                            const Divider(),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.between,
                                              children: [
                                                Text('Received Weight: ${conf.receivedQuantity.toStringAsFixed(0)} kg', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                                                if (conf.expectedQuantityKg != null)
                                                  Text('Expected: ${conf.expectedQuantityKg!.toStringAsFixed(0)} kg', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text('Receiver: ${conf.receiverName ?? "Produce Hub"}', style: const TextStyle(fontSize: 12)),
                                            Text('Confirmed At: ${conf.confirmedAt.length >= 16 ? conf.confirmedAt.substring(0, 16).replaceAll("T", " ") : conf.confirmedAt}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                            if (conf.issueNotes != null && conf.issueNotes!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 6),
                                                child: Text('Discrepancy Notes: ${conf.issueNotes}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.redAccent)),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
