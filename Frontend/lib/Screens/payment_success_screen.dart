import 'package:flutter/material.dart';
import 'home_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String paymentId;
  final String orderId;
  final int totalAmount;
  final String paymentMethod;
  final String email;
  final String token;

  const PaymentSuccessScreen({
    required this.paymentId,
    required this.orderId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.email,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Success Animation
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green[100],
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 60,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 24),
                // Success Title
                Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 8),
                // Success Message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Your order has been confirmed and will be processed soon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Payment Details Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    children: [
                      // Order ID
                      _buildDetailRow(
                        label: 'Order ID',
                        value: orderId,
                        isHighlight: true,
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.green[200], height: 1),
                      const SizedBox(height: 16),
                      // Payment ID
                      _buildDetailRow(
                        label: 'Payment ID',
                        value: paymentId,
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.green[200], height: 1),
                      const SizedBox(height: 16),
                      // Payment Method
                      _buildDetailRow(
                        label: 'Payment Method',
                        value: paymentMethod == 'UPI'
                            ? 'UPI'
                            : 'Debit/Credit Card',
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.green[200], height: 1),
                      const SizedBox(height: 16),
                      // Amount
                      _buildDetailRow(
                        label: 'Amount Paid',
                        value: '₹$totalAmount',
                        isAmount: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // What's Next
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "What's Next?",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildNextStep(
                        number: '1',
                        title: 'Order Confirmation',
                        description:
                            'We\'ve sent a confirmation email with order details.',
                      ),
                      const SizedBox(height: 12),
                      _buildNextStep(
                        number: '2',
                        title: 'Processing',
                        description:
                            'Your order will be packed and prepared for shipping.',
                      ),
                      const SizedBox(height: 12),
                      _buildNextStep(
                        number: '3',
                        title: 'Delivery',
                        description:
                            'You\'ll receive tracking updates via email.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
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
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) =>
                            HomeScreen(email: email, token: token),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Navigate to Order History
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Order history coming soon!')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green[700]!),
                  ),
                  child: Text(
                    'View Order',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isHighlight = false,
    bool isAmount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isAmount ? 16 : 13,
              fontWeight:
                  isHighlight || isAmount ? FontWeight.bold : FontWeight.w500,
              color: isHighlight || isAmount
                  ? Colors.green[700]
                  : Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue[700],
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
