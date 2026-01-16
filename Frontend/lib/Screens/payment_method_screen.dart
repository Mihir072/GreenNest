import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greennest/Services/api_service.dart';
import 'package:greennest/Widget/custom_toast.dart';
import 'upi_payment_screen.dart';
import 'card_payment_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String orderId;
  final int totalAmount;
  final String userToken;
  final String userId;

  const PaymentMethodScreen({
    required this.orderId,
    required this.totalAmount,
    required this.userToken,
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selectedMethod = 'UPI';
  bool _isLoading = false;

  Future<void> _initiatePayment() async {
    setState(() => _isLoading = true);

    try {
      final paymentData = {
        'orderId': widget.orderId,
        'userId': widget.userId,
        'paymentMethod': _selectedMethod,
        'amount': widget.totalAmount,
      };

      final response = await ApiService.initiatePayment(
        paymentData,
        token: widget.userToken,
      );

      print('Payment Initiate Response Status: ${response.statusCode}');
      print('Payment Initiate Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final paymentId = responseData['paymentId'] ?? '';

        if (mounted) {
          if (_selectedMethod == 'UPI') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => UPIPaymentScreen(
                  paymentId: paymentId,
                  orderId: widget.orderId,
                  totalAmount: widget.totalAmount,
                  userToken: widget.userToken,
                ),
              ),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => CardPaymentScreen(
                  paymentId: paymentId,
                  orderId: widget.orderId,
                  totalAmount: widget.totalAmount,
                  userToken: widget.userToken,
                ),
              ),
            );
          }
        }
      } else {
        print('Payment initiate failed with status: ${response.statusCode}');
        CustomToast.error(
          title: 'Payment Failed',
          message: 'Unable to initiate payment. Try again',
        );
      }
    } catch (e) {
      CustomToast.error(
        title: 'Error Occurred',
        message: 'Something went wrong during payment',
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Amount Display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${widget.totalAmount}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          // Payment Methods
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // UPI Option
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: RadioListTile<String>(
                      value: 'UPI',
                      groupValue: _selectedMethod,
                      onChanged: (value) {
                        setState(() => _selectedMethod = value!);
                      },
                      title: const Text(
                        'UPI Payment',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                          'Pay using UPI, Google Pay, PhonePe, etc.'),
                      secondary: Icon(
                        Icons.phone_android,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                  // Card Option
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: RadioListTile<String>(
                      value: 'CARD',
                      groupValue: _selectedMethod,
                      onChanged: (value) {
                        setState(() => _selectedMethod = value!);
                      },
                      title: const Text(
                        'Debit / Credit Card',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Visa, Mastercard, Rupay, etc.'),
                      secondary: Icon(
                        Icons.credit_card,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Payment Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your payment is secure and encrypted.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Continue Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _initiatePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
