import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../utils/budget_tracker.dart';
import '../utils/image_compression.dart';

class PriceTagScannerWidget extends StatefulWidget {
  final BudgetTracker budgetTracker;

  const PriceTagScannerWidget({
    Key? key,
    required this.budgetTracker,
  }) : super(key: key);

  @override
  State<PriceTagScannerWidget> createState() => _PriceTagScannerWidgetState();
}

class _PriceTagScannerWidgetState extends State<PriceTagScannerWidget>
    with SingleTickerProviderStateMixin {
  final ImagePicker _imagePicker = ImagePicker();
  final ApiService _apiService = ApiService();

  bool _isScanning = false;
  double? _detectedPrice;
  String? _detectedCategory;
  String? _scanMessage;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _scanPriceTag() async {
    try {
      setState(() => _isScanning = true);

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) {
        setState(() => _isScanning = false);
        return;
      }

      // Compress image before OCR
      final compressedPath = await ImageCompressionUtil.compressReceiptImage(
        image.path,
      );

      // Call OCR endpoint to detect price and category
      final ocrResult = await _apiService.scanReceiptText(
        imagePath: compressedPath,
      );

      // Extract price and category (default to Shopping for now)
      final detectedPrice = ocrResult.amount;
      const detectedCategory = 'Shopping';

      if (detectedPrice != null && detectedPrice > 0) {
        setState(() {
          _detectedPrice = detectedPrice;
          _detectedCategory = detectedCategory;
          _scanMessage =
              'Found ₹${detectedPrice.toStringAsFixed(2)} in $detectedCategory';
        });

        // Show fade in animation
        _fadeController.forward(from: 0.0);

        // Show confirmation dialog
        _showPriceConfirmationDialog(detectedPrice, detectedCategory);
      } else {
        setState(() {
          _scanMessage = 'Could not detect price. Please try again.';
        });
        _showSnackBar(_scanMessage!, Colors.orange);
      }
    } catch (e) {
      setState(() {
        _scanMessage = 'Error scanning price tag: $e';
      });
      _showSnackBar(_scanMessage!, Colors.red);
    } finally {
      setState(() => _isScanning = false);
    }
  }

  /// Categorize price based on merchant or amount heuristics
  String _categorizePrice(String merchant) {
    final merchantLower = merchant.toLowerCase();

    // Food & Dining
    if (merchantLower.contains('restaurant') ||
        merchantLower.contains('cafe') ||
        merchantLower.contains('food') ||
        merchantLower.contains('pizza') ||
        merchantLower.contains('burger')) {
      return 'Food & Dining';
    }

    // Transport
    if (merchantLower.contains('transport') ||
        merchantLower.contains('uber') ||
        merchantLower.contains('ola') ||
        merchantLower.contains('petrol') ||
        merchantLower.contains('gas')) {
      return 'Transport';
    }

    // Shopping
    if (merchantLower.contains('shop') ||
        merchantLower.contains('mall') ||
        merchantLower.contains('store') ||
        merchantLower.contains('amazon') ||
        merchantLower.contains('flipkart')) {
      return 'Shopping';
    }

    // Entertainment
    if (merchantLower.contains('cinema') ||
        merchantLower.contains('movie') ||
        merchantLower.contains('game') ||
        merchantLower.contains('club')) {
      return 'Entertainment';
    }

    // Default
    return 'Other';
  }

  void _showPriceConfirmationDialog(double price, String category) {
    final remaining = widget.budgetTracker.getCategory(category)?.remaining ?? 0;
    final remaining_after = remaining - price;
    final isOverBudget = remaining_after < 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Amount:', '₹$price'),
              const SizedBox(height: 12),
              _buildDetailRow('Category:', category),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Current Budget:',
                '₹${remaining.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Remaining After:',
                '₹${remaining_after.toStringAsFixed(2)}',
                color: isOverBudget ? Colors.red : Colors.green,
              ),
              if (isOverBudget) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Over budget by ₹${(price - remaining).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.budgetTracker.deductFromCategory(category, price);
              Navigator.pop(context);
              _showSnackBar(
                'Deducted ₹$price from $category budget',
                Colors.green,
              );
              setState(() {
                _fadeController.forward(from: 0.0);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isOverBudget ? Colors.orange : Colors.green,
            ),
            child: const Text('Confirm Purchase'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner,
                    color: Colors.blue.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price Tag Scanner',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Scan items before buying',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Scan Button
            ElevatedButton.icon(
              onPressed: _isScanning ? null : _scanPriceTag,
              icon: _isScanning
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade700,
                        ),
                      ),
                    )
                  : const Icon(Icons.camera_alt),
              label: Text(
                _isScanning ? 'Scanning...' : 'Scan Price Tag',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Scan Result with Animation
            if (_detectedPrice != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amount: ₹${_detectedPrice?.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Category: $_detectedCategory',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
