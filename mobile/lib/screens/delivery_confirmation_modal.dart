import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class DeliveryConfirmationModal extends StatefulWidget {
  final Map<String, dynamic> delivery;
  final VoidCallback onConfirmed;

  const DeliveryConfirmationModal({
    super.key,
    required this.delivery,
    required this.onConfirmed,
  });

  @override
  State<DeliveryConfirmationModal> createState() => _DeliveryConfirmationModalState();
}

class _DeliveryConfirmationModalState extends State<DeliveryConfirmationModal> {
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  String _selectedRating = 'EXCELLENT';
  bool _isSubmitting = false;

  final List<String> _ratings = ['EXCELLENT', 'GOOD', 'ACCEPTABLE', 'DAMAGED'];

  @override
  void initState() {
    super.initState();
    final weight = (widget.delivery['totalWeightKg'] as num?)?.toDouble() ?? 5000.0;
    _quantityController = TextEditingController(text: weight.toStringAsFixed(0));
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitConfirmation() async {
    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid received quantity (kg)')),
      );
      return;
    }

    final auth = Provider.of<AuthService>(context, listen: false);
    if (auth.token == null) return;

    setState(() => _isSubmitting = true);
    try {
      final tripId = widget.delivery['tripId'] ?? widget.delivery['id'];
      await ApiService.confirmDelivery(
        auth.token!,
        tripId,
        receivedQuantity: quantity,
        conditionRating: _selectedRating,
        issueNotes: _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onConfirmed();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delivery receipt confirmed successfully! Crop set to SOLD.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error confirming delivery: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
    final cropName = widget.delivery['cropName'] ?? 'Farm Produce';
    final driverName = widget.delivery['driverName'] ?? 'Driver';
    final plate = widget.delivery['vehiclePlate'] ?? 'N/A';
    final expectedWeight = (widget.delivery['totalWeightKg'] as num?)?.toDouble() ?? 5000.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified, color: AppColors.primaryGreen, size: 24),
                    SizedBox(width: 8),
                    Text('Confirm Delivery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Cargo and Driver Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cargo: $cropName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Driver: $driverName ($plate)', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  Text('Expected Weight: ${expectedWeight.toStringAsFixed(0)} kg', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Received Quantity input
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Actual Received Quantity (kg)',
                prefixIcon: Icon(Icons.scale),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Condition Rating Selector
            const Text('Cargo Condition Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _ratings.map((rating) {
                final isSelected = _selectedRating == rating;
                final color = _getRatingColor(rating);
                return ChoiceChip(
                  label: Text(
                    rating,
                    style: TextStyle(
                      color: isSelected ? Colors.white : color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: color,
                  backgroundColor: color.withOpacity(0.1),
                  onSelected: (val) {
                    if (val) setState(() => _selectedRating = rating);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Issue Notes Field
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Discrepancy / Inspection Notes (Optional)',
                hintText: 'e.g. Minor outer box moisture or 10kg damaged in transit',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Confirm Receipt & Finalize', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
