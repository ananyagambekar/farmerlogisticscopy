import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crop.dart';
import '../models/booking.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'live_tracking_screen.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CropListing> _crops = [];
  List<TransportBooking> _bookings = [];
  bool _loading = true;
  String _searchQuery = '';
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
      final crops = await ApiService.getCrops(token);
      final bookings = await ApiService.getBookings(token);
      setState(() {
        _crops = crops;
        _bookings = bookings;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Add / Edit Crop Dialog with Validation
  void _showCropDialog({CropListing? existingCrop}) {
    final formKey = GlobalKey<FormState>();
    final cropTypeCtrl = TextEditingController(text: existingCrop?.cropType ?? '');
    final qtyCtrl = TextEditingController(text: existingCrop != null ? existingCrop.quantityKg.toString() : '');
    final priceCtrl = TextEditingController(text: existingCrop != null ? existingCrop.askingPricePerKg.toString() : '');
    final locationCtrl = TextEditingController(text: existingCrop?.location ?? 'Nakuru North Farm');
    final notesCtrl = TextEditingController(text: existingCrop?.description ?? '');

    String selectedUnit = existingCrop?.unit ?? 'kg';
    DateTime selectedHarvestDate = existingCrop != null && existingCrop.harvestDate.isNotEmpty
        ? DateTime.tryParse(existingCrop.harvestDate) ?? DateTime.now()
        : DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(existingCrop == null ? 'Add Crop Listing' : 'Edit Crop Listing'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: cropTypeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Crop Name / Type *',
                        hintText: 'e.g., Maize (Grade A), Tomatoes',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter crop name' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: qtyCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Quantity *',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Enter quantity';
                              final numVal = double.tryParse(v);
                              if (numVal == null || numVal <= 0) return 'Must be > 0';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: selectedUnit,
                            decoration: const InputDecoration(labelText: 'Unit'),
                            items: const [
                              DropdownMenuItem(value: 'kg', child: Text('kg')),
                              DropdownMenuItem(value: 'Ton', child: Text('Ton')),
                              DropdownMenuItem(value: 'Bag', child: Text('Bag')),
                              DropdownMenuItem(value: 'Crate', child: Text('Crate')),
                            ],
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedUnit = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Expected Price per unit (KES) *',
                        hintText: 'e.g., 45',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter price';
                        final numVal = double.tryParse(v);
                        if (numVal == null || numVal <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: locationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Pickup Location *',
                        hintText: 'e.g., Nakuru Farm, Section 4',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter location' : null,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedHarvestDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedHarvestDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Harvest Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${selectedHarvestDate.day}/${selectedHarvestDate.month}/${selectedHarvestDate.year}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes / Description',
                        hintText: 'Optional harvest details or quality notes',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final token = Provider.of<AuthService>(context, listen: false).token;
                    if (token == null) return;

                    final cropData = {
                      'cropType': cropTypeCtrl.text.trim(),
                      'quantityKg': double.parse(qtyCtrl.text.trim()),
                      'unit': selectedUnit,
                      'askingPricePerKg': double.parse(priceCtrl.text.trim()),
                      'location': locationCtrl.text.trim(),
                      'harvestDate': selectedHarvestDate.toIso8601String(),
                      'description': notesCtrl.text.trim(),
                    };

                    try {
                      if (existingCrop == null) {
                        await ApiService.createCrop(token, cropData);
                      } else {
                        await ApiService.updateCrop(token, existingCrop.id, cropData);
                      }
                      if (mounted) {
                        Navigator.pop(ctx);
                        _loadData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(existingCrop == null ? 'Crop listed successfully!' : 'Crop updated successfully!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  }
                },
                child: Text(existingCrop == null ? 'Save Listing' : 'Update Listing'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Delete Confirmation
  void _confirmDeleteCrop(CropListing crop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Crop Listing'),
        content: Text('Are you sure you want to delete "${crop.cropType}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final token = Provider.of<AuthService>(context, listen: false).token;
              if (token != null) {
                try {
                  await ApiService.deleteCrop(token, crop.id);
                  if (mounted) {
                    Navigator.pop(ctx);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Crop listing deleted')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Transport Booking Dialog
  void _showBookingDialog({CropListing? preselectedCrop}) {
    final formKey = GlobalKey<FormState>();
    CropListing? selectedCrop = preselectedCrop ?? (_crops.isNotEmpty ? _crops.first : null);
    final pickupCtrl = TextEditingController(text: selectedCrop?.location ?? 'Nakuru North Farm');
    final destCtrl = TextEditingController(text: 'Nairobi Central Wholesale Market');
    final weightCtrl = TextEditingController(text: selectedCrop != null ? selectedCrop.quantityKg.toString() : '1000');

    String selectedVehicle = '3-Ton Truck';
    DateTime targetDate = DateTime.now().add(const Duration(days: 1));
    double estimatedCost = 0.0;
    bool estimating = false;

    void updateEstimate(StateSetter setDialogState) async {
      final token = Provider.of<AuthService>(context, listen: false).token;
      if (token == null) return;

      final w = double.tryParse(weightCtrl.text) ?? 1000;
      setDialogState(() => estimating = true);
      try {
        final est = await ApiService.estimateTransportCost(token, {
          'pickupLocation': pickupCtrl.text,
          'destinationLocation': destCtrl.text,
          'estimatedWeight': w,
          'requiredVehicleType': selectedVehicle,
        });
        setDialogState(() {
          estimatedCost = est;
          estimating = false;
        });
      } catch (e) {
        setDialogState(() => estimating = false);
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          if (estimatedCost == 0.0 && !estimating) {
            updateEstimate(setDialogState);
          }

          return AlertDialog(
            title: const Text('Book Transport Service'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_crops.isNotEmpty)
                      DropdownButtonFormField<CropListing>(
                        value: selectedCrop,
                        decoration: const InputDecoration(labelText: 'Select Crop Listing'),
                        items: _crops.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text('${c.cropType} (${c.quantityKg} ${c.unit})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedCrop = val;
                              pickupCtrl.text = val.location;
                              weightCtrl.text = val.quantityKg.toString();
                            });
                            updateEstimate(setDialogState);
                          }
                        },
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: pickupCtrl,
                      decoration: const InputDecoration(labelText: 'Pickup Location *'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      onChanged: (_) => updateEstimate(setDialogState),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: destCtrl,
                      decoration: const InputDecoration(labelText: 'Destination Location *'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      onChanged: (_) => updateEstimate(setDialogState),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: weightCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Est. Weight (kg) *'),
                            validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                            onChanged: (_) => updateEstimate(setDialogState),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedVehicle,
                            decoration: const InputDecoration(labelText: 'Vehicle Type'),
                            items: const [
                              DropdownMenuItem(value: 'Pickup Truck', child: Text('Pickup')),
                              DropdownMenuItem(value: '3-Ton Truck', child: Text('3-Ton')),
                              DropdownMenuItem(value: '10-Ton Truck', child: Text('10-Ton')),
                              DropdownMenuItem(value: 'Refrigerated Truck', child: Text('Refrigerated')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => selectedVehicle = val);
                                updateEstimate(setDialogState);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: targetDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (picked != null) {
                          setDialogState(() => targetDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Target Delivery Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text('${targetDate.day}/${targetDate.month}/${targetDate.year}'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Estimation Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          const Text('Estimated Fare:', style: TextStyle(fontWeight: FontWeight.bold)),
                          estimating
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(
                                  'KES ${estimatedCost.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryGreen),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final token = Provider.of<AuthService>(context, listen: false).token;
                    if (token == null) return;

                    try {
                      await ApiService.createBooking(token, {
                        'cropListingId': selectedCrop?.id,
                        'pickupLocation': pickupCtrl.text.trim(),
                        'destinationLocation': destCtrl.text.trim(),
                        'estimatedWeight': double.parse(weightCtrl.text.trim()),
                        'requiredVehicleType': selectedVehicle,
                        'estimatedPrice': estimatedCost,
                        'targetDeliveryDate': targetDate.toIso8601String(),
                      });

                      if (mounted) {
                        Navigator.pop(ctx);
                        _loadData();
                        _tabController.animateTo(2); // Switch to History
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transport request submitted successfully!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  }
                },
                child: const Text('Submit Request'),
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

    // Filter crops
    List<CropListing> filteredCrops = _crops.where((c) {
      final matchesSearch = _searchQuery.isEmpty ||
          c.cropType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.location.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'ALL' || c.status.toUpperCase() == _statusFilter.toUpperCase();
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.eco), text: 'My Crops'),
            Tab(icon: Icon(Icons.local_shipping), text: 'Book Transport'),
            Tab(icon: Icon(Icons.history), text: 'Bookings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: CROP MANAGEMENT
          RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Banner
                  Card(
                    color: AppColors.primaryGreen,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.white24,
                            radius: 24,
                            child: Icon(Icons.agriculture, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, ${user?.fullName ?? 'Farmer'}!',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Text(
                                  'Manage crop inventory & request logistics',
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

                  // Actions & Search Bar
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showCropDialog(),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('List New Crop'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search & Filter
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: const InputDecoration(
                            hintText: 'Search crops or location...',
                            prefixIcon: Icon(Icons.search),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _statusFilter,
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('All Status')),
                          DropdownMenuItem(value: 'AVAILABLE', child: Text('Available')),
                          DropdownMenuItem(value: 'RESERVED', child: Text('Reserved')),
                          DropdownMenuItem(value: 'SOLD', child: Text('Sold')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _statusFilter = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Crop List
                  if (_loading)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  else if (filteredCrops.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.eco_outlined, size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              const Text('No crop listings found.', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              const Text('Tap "List New Crop" above to create your first listing.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredCrops.length,
                      itemBuilder: (ctx, idx) {
                        final crop = filteredCrops[idx];
                        final statusColor = _getStatusColor(crop.status);
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
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: AppColors.lightGreen,
                                          child: Icon(Icons.eco, color: AppColors.primaryGreen),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(crop.cropType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            Text('${crop.location}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: statusColor),
                                      ),
                                      child: Text(
                                        crop.status,
                                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Quantity: ${crop.quantityKg} ${crop.unit}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text('KES ${crop.askingPricePerKg}/${crop.unit}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                                  ],
                                ),
                                if (crop.description != null && crop.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text('Notes: "${crop.description}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
                                  ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => _showBookingDialog(preselectedCrop: crop),
                                      icon: const Icon(Icons.local_shipping, size: 16),
                                      label: const Text('Book Freight', style: TextStyle(fontSize: 12)),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                      onPressed: () => _showCropDialog(existingCrop: crop),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      onPressed: () => _confirmDeleteCrop(crop),
                                    ),
                                  ],
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

          // TAB 2: TRANSPORT BOOKING FLOW
          SingleChildScrollView(
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
                          child: Icon(Icons.local_shipping, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Request Produce Transport', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Instant estimation & regional agent dispatch', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showBookingDialog(),
                  icon: const Icon(Icons.add_road),
                  label: const Text('Create New Transport Request'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
                ),
                const SizedBox(height: 24),
                const Text('Quick Booking Guidance:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                const ListTile(
                  leading: CircleAvatar(child: Text('1')),
                  title: Text('Select crop and pickup location'),
                  subtitle: Text('Choose produce from active listings or type custom origin.'),
                ),
                const ListTile(
                  leading: CircleAvatar(child: Text('2')),
                  title: Text('Get automated tariff calculation'),
                  subtitle: Text('Estimated cost updates automatically based on weight and vehicle rate.'),
                ),
                const ListTile(
                  leading: CircleAvatar(child: Text('3')),
                  title: Text('Agent dispatch & driver assignment'),
                  subtitle: Text('Agents review incoming requests and assign registered vehicles.'),
                ),
              ],
            ),
          ),

          // TAB 3: BOOKING HISTORY
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
                      const Text('Transport Booking History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${_bookings.length} requests', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_loading)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  else if (_bookings.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('No transport requests submitted yet.')),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _bookings.length,
                      itemBuilder: (ctx, idx) {
                        final b = _bookings[idx];
                        final statusColor = _getStatusColor(b.status);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.between,
                              children: [
                                Text('${b.origin} ➔ ${b.destination}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: statusColor),
                                  ),
                                  child: Text(b.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text('Weight: ${b.totalWeightKg} kg • Vehicle: ${b.vehicleTypeRequired}'),
                                if (b.driverName != null)
                                  Text('Driver: ${b.driverName} (${b.vehiclePlate ?? 'Assigned'})', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.between,
                                  children: [
                                    Text('Est. Price: KES ${b.estimatedCost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.gps_fixed, size: 14, color: Colors.white),
                                      label: const Text('Track Live', style: TextStyle(fontSize: 11, color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryGreen,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        minimumSize: Size.zero,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => LiveTrackingScreen(tripId: 'trip-001')),
                                        );
                                      },
                                    ),
                                  ],
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
        ],
      ),
    );
  }
}
