import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greennest/Services/api_service.dart';
import 'package:greennest/Widget/custom_toast.dart';
import 'payment_success_screen.dart';
import 'payment_error_screen.dart';

class UPIPaymentScreen extends StatefulWidget {
  final String paymentId;
  final String orderId;
  final int totalAmount;
  final String userToken;

  const UPIPaymentScreen({
    required this.paymentId,
    required this.orderId,
    required this.totalAmount,
    required this.userToken,
    Key? key,
  }) : super(key: key);

  @override
  State<UPIPaymentScreen> createState() => _UPIPaymentScreenState();
}

class _UPIPaymentScreenState extends State<UPIPaymentScreen> {
  final TextEditingController _upiController = TextEditingController();
  bool _isLoading = false;
  bool _showQRCode = true;

  // UPI string for QR code
  String _generateUPIString() {
    return 'upi://pay?pa=merchant@okhdfcbank&pn=GreenNest%20Store&am=${widget.totalAmount}&tn=GreenNest%20Order%20${widget.orderId}&tr=${widget.paymentId}';
  }

  bool _validateUPI(String upi) {
    // UPI ID format: username@bankname (e.g., user@okhdfcbank)
    final upiRegex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9]+$');
    return upiRegex.hasMatch(upi);
  }

  Future<void> _verifyPayment(bool isSuccess, {String? failureReason}) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.verifyPayment(
        widget.paymentId,
        isSuccess: isSuccess,
        failureReason: failureReason ?? '',
        token: widget.userToken,
      );

      if (response.statusCode == 200) {
        if (isSuccess && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                paymentId: widget.paymentId,
                orderId: widget.orderId,
                totalAmount: widget.totalAmount,
                paymentMethod: 'UPI',
                email: '', // Add your email parameter
                token: widget.userToken,
              ),
            ),
          );
        } else if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PaymentErrorScreen(
                orderId: widget.orderId,
                paymentId: widget.paymentId,
                failureReason:
                    failureReason ?? 'Payment could not be processed',
                userToken: widget.userToken,
              ),
            ),
          );
        }
      } else {
        CustomToast.error(
          title: 'Payment Failed',
          message: 'Could not verify payment',
        );
      }
    } catch (e) {
      CustomToast.error(
        title: 'Payment Error',
        message: 'Something went wrong',
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI Payment',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Amount Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  const Text(
                    'Amount to Pay',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${widget.totalAmount}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Tab Selection
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _showQRCode = true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _showQRCode
                                ? Colors.green[700]!
                                : Colors.grey[300]!,
                            width: _showQRCode ? 3 : 1,
                          ),
                        ),
                      ),
                      child: Text(
                        'QR Code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _showQRCode ? Colors.green[700] : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _showQRCode = false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: !_showQRCode
                                ? Colors.green[700]!
                                : Colors.grey[300]!,
                            width: !_showQRCode ? 3 : 1,
                          ),
                        ),
                      ),
                      child: Text(
                        'Manual Entry',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: !_showQRCode ? Colors.green[700] : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Content based on tab
            if (_showQRCode) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    // QR Code placeholder (In production, use qr_flutter package)
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                      ),
                      child: Icon(
                        Icons.qr_code_2,
                        size: 200,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan with UPI App',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use Google Pay, PhonePe, or your bank\'s app to scan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Or enter UPI ID manually',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (!_showQRCode) ...[
              TextField(
                controller: _upiController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Enter UPI ID',
                  hintText: 'user@okhdfcbank',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon:
                      Icon(Icons.account_balance, color: Colors.green[700]),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Format: username@bankname\nExample: john@okhdfcbank',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 32),
            // Payment Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Payment Instructions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _showQRCode
                        ? '1. Open your preferred UPI app (Google Pay, PhonePe, etc.)\n2. Scan the QR code above\n3. Verify the amount\n4. Confirm payment'
                        : '1. Enter your UPI ID\n2. Click "Pay Now"\n3. Confirm in your UPI app\n4. Verify the amount',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border(
            top: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_showQRCode ||
                            _upiController.text.isEmpty ||
                            _validateUPI(_upiController.text)) {
                          _verifyPayment(true);
                        } else {
                          CustomToast.warning(
                            title: 'Invalid UPI ID',
                            message: 'Enter a valid UPI ID (e.g., user@okhdfcbank)',
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Pay Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () =>
                      _verifyPayment(false, failureReason: 'User cancelled'),
              child: Text(
                'Cancel Payment',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
