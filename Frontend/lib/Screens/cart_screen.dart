// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greennest/Util/colors.dart';
import 'package:greennest/services/api_service.dart';
import 'package:greennest/Widget/custom_toast.dart';
import 'package:greennest/Util/icons.dart';
import 'package:greennest/Util/strings.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final String token;
  final String email;
  final List<dynamic> cart;
  final VoidCallback? onOrderPlaced;
  final void Function(List<dynamic>)? onCartUpdated;

  const CartScreen(
      {super.key,
      required this.token,
      required this.cart,
      required this.email,
      this.onOrderPlaced,
      this.onCartUpdated});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, dynamic> userInfo = {};
  late List<dynamic> cart;
  bool isLoadingOrder = false;

  @override
  void initState() {
    super.initState();
    cart = List.from(widget.cart);
    loadUserInfo();
  }

  void increaseQuantity(int index) {
    setState(() {
      cart[index]['quantity']++;
    });
  }

  void decreaseQuantity(int index) {
    setState(() {
      if (cart[index]['quantity'] > 1) {
        cart[index]['quantity']--;
      }
    });
  }

  int getTotalAmount() {
    return cart.fold(
        0,
        (sum, item) =>
            sum + ((item['price'] as num) * (item['quantity'] as num)).toInt());
  }

  Future<void> loadUserInfo() async {
    final response = await ApiService.getUserByEmail(widget.email);
    if (response.statusCode == 200) {
      setState(() {
        userInfo = jsonDecode(response.body);
      });
    }
  }

  void placeOrder() async {
    if (isLoadingOrder) return; // Prevent duplicate requests

    // Validate cart is not empty
    if (cart.isEmpty) {
      CustomToast.warning(
        title: 'Cart is Empty',
        message: 'Add items to your cart before proceeding to checkout.',
      );
      return;
    }

    // Validate user info is loaded
    if (userInfo.isEmpty) {
      CustomToast.error(
        title: 'Profile Loading',
        message: 'We\'re loading your profile. Please try again in a moment.',
      );
      return;
    }

    setState(() {
      isLoadingOrder = true;
    });

    try {
      final totalAmount = getTotalAmount();
      final address = userInfo['address'] ?? '';
      final name = userInfo['name'] ?? '';
      final userId = userInfo['id'] ?? '';

      // Convert cart items to the format expected by checkout screen
      final cartItems = cart
          .map((item) => {
                'id': item['id'],
                'name': item['name'],
                'price': item['price'],
                'quantity': item['quantity'],
                'imageUrl': item['imageUrl'] ?? '',
              })
          .toList();

      setState(() {
        isLoadingOrder = false;
      });

      // Navigate to checkout screen with order details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            cartItems: cartItems.cast<Map<String, dynamic>>(),
            userToken: widget.token,
            userId: userId,
            userName: name,
            userEmail: widget.email,
            userAddress: address,
          ),
        ),
      ).then((result) {
        // When returning from checkout/payment, refresh the cart
        if (result == true) {
          setState(() {
            cart.clear();
          });
          CustomToast.success(
            title: 'Order Placed',
            message: 'Your order has been placed successfully!',
          );
          widget.onOrderPlaced?.call();
        }
      });
    } catch (e) {
      setState(() {
        isLoadingOrder = false;
      });
      CustomToast.error(
        title: 'Order Failed',
        message:
            'Unable to place order. Please check your details and try again.',
      );
      print('Error processing order: $e');
    }
  }

  void removeItem(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Item"),
        content: const Text(
            "Are you sure you want to remove this item from the cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        cart.removeAt(index);
      });
      widget.onCartUpdated?.call(cart);
      CustomToast.info(
        title: 'Item Removed',
        message: 'Plant has been removed from cart',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add plants to your cart to get started',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      final itemTotal =
                          (item['price'] as num) * (item['quantity'] as num);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: item['imageUrl'] != null
                                        ? Image.network(
                                            item['imageUrl'],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[300],
                                                child: Icon(Icons.image,
                                                    color: Colors.grey[600]),
                                              );
                                            },
                                          )
                                        : Icon(Icons.image,
                                            color: Colors.grey[600]),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${item['price']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Quantity Control
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () =>
                                                  decreaseQuantity(index),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                child: Icon(Icons.remove,
                                                    size: 18,
                                                    color: Colors.grey[700]),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4),
                                              color: Colors.grey[100],
                                              child: Text(
                                                '${item['quantity']}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () =>
                                                  increaseQuantity(index),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                child: Icon(Icons.add,
                                                    size: 18,
                                                    color: Colors.green[700]),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Price and Delete
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${itemTotal.toInt()}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () => removeItem(index),
                                      child: Icon(Icons.delete_outline,
                                          size: 20, color: Colors.red[600]),
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
                ),
                // Order Summary Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Order Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '₹${getTotalAmount()}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delivery',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Free',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '₹${getTotalAmount()}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Place Order Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoadingOrder ? null : placeOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            disabledBackgroundColor: Colors.grey[400],
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoadingOrder
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.green[700],
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Place Order',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
