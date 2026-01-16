// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:greennest/Helper/email_request.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.189.155.205:8081';

  static Future<http.Response> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      return response;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  //--------------------- REGISTER ---------------------//

  static Future<http.Response> registerUser({
    required String name,
    required String email,
    required String password,
    required String address,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/register');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'address': address,
              'role': 'USER',
            }),
          )
          .timeout(
            const Duration(seconds: 30),
          );
      return response;
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }

  //--------------------- LOGIN ---------------------//

  static Future<http.Response> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
          );
      return response;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  //--------------------- FORGOT PASSWORD ---------------------//

  static Future<http.Response> forgotPassword({
    required String email,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/auth/passwordForgot/$email');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'password': newPassword,
      }),
    );
    return response;
  }

  //--------------------- SHOW ALL PLANTS ---------------------//

  static Future<http.Response> getPlants({
    String? category,
    int page = 0,
    int size = 12,
  }) async {
    try {
      String url = '$baseUrl/plants?page=$page&size=$size';
      if (category != null && category.isNotEmpty) {
        url += '&category=$category';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to fetch plants: $e');
    }
  }

  //--------------------- SEARCH PLANTS BY NAME ---------------------//

  static Future<http.Response> searchPlants(
    String query, {
    String? category,
  }) async {
    try {
      String url = '$baseUrl/plants/search?q=$query';
      if (category != null && category.isNotEmpty) {
        url += '&category=$category';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to search plants: $e');
    }
  }

  //--------------------- PLACE ORDER ---------------------//

  static Future<http.Response> placeOrder({
    required String token,
    required List<Map<String, dynamic>> items,
    required int totalAmount,
    required String address,
    required String name,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/orders/place'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'items': items,
              'totalAmount': totalAmount,
              'address': address,
              'name': name
            }),
          )
          .timeout(
            const Duration(seconds: 30),
          );
      return response;
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  //--------------------- GET MY ORDERS ---------------------//

  static Future<http.Response> getMyOrders({required String token}) async {
    return await http.get(
      Uri.parse('$baseUrl/orders/my-orders'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  //--------------------- GET USER INFO ---------------------//

  static Future<http.Response> getUserByEmail(String email) async {
    return await http.get(Uri.parse('$baseUrl/auth/users/$email'));
  }

  //--------------------- Email Sending ---------------------//

  static Future<http.Response> sendOrderEmail({
    required String token,
    required EmailRequest emailRequest,
  }) async {
    final url = Uri.parse('$baseUrl/orders/send-confirmation-email');

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(emailRequest.toJson()),
    );
  }

  //--------------------- Logout ---------------------//

  static Future<http.Response> logout(String token) async {
    final url = Uri.parse('$baseUrl/auth/logout');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  //--------------------- ADMIN PLANTS ---------------------//

  static Future<http.Response> getAdminPlants({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/plants'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to fetch admin plants: $e');
    }
  }

  static Future<http.Response> createAdminPlant(
    Map<String, dynamic> plantData, {
    required String token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/admin/plants'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(plantData),
          )
          .timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to create plant: $e');
    }
  }

  static Future<http.Response> updateAdminPlant(
    String plantId,
    Map<String, dynamic> plantData, {
    required String token,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/api/admin/plants/$plantId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(plantData),
          )
          .timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to update plant: $e');
    }
  }

  static Future<http.Response> deleteAdminPlant(
    String plantId, {
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/admin/plants/$plantId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to delete plant: $e');
    }
  }

  //--------------------- ADMIN CATEGORIES ---------------------//

  static Future<http.Response> getAdminCategories(
      {required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to fetch admin categories: $e');
    }
  }

  static Future<http.Response> createAdminCategory(
    Map<String, dynamic> categoryData, {
    required String token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/admin/categories'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(categoryData),
          )
          .timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  static Future<http.Response> updateAdminCategory(
    String categoryId,
    Map<String, dynamic> categoryData, {
    required String token,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/api/admin/categories/$categoryId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(categoryData),
          )
          .timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  static Future<http.Response> deleteAdminCategory(
    String categoryId, {
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/admin/categories/$categoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  //--------------------- ADMIN USERS ---------------------//

  static Future<http.Response> getAdminUsers({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  static Future<http.Response> getAdminUserById(
    String userId, {
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  static Future<http.Response> updateAdminUser(
    String userId,
    Map<String, dynamic> userData, {
    required String token,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/auth/users/$userId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(userData),
          )
          .timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  static Future<http.Response> deleteAdminUser(
    String userId, {
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  //--------------------- ADMIN ORDERS ---------------------//

  static Future<http.Response> getAdminOrders({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  static Future<http.Response> getAdminOrdersByUser(
    String userId, {
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/orders/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to fetch user orders: $e');
    }
  }

  static Future<http.Response> getAdminOrderById(
    String orderId, {
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  //--------------------- PAYMENTS ---------------------//

  static Future<http.Response> createOrder(
    Map<String, dynamic> orderData, {
    required String token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/orders/place'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(orderData),
          )
          .timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  static Future<http.Response> initiatePayment(
    Map<String, dynamic> paymentData, {
    required String token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/payments/initiate'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(paymentData),
          )
          .timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to initiate payment: $e');
    }
  }

  static Future<http.Response> verifyPayment(
    String paymentId, {
    required bool isSuccess,
    required String failureReason,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/api/payments/verify?paymentId=$paymentId&isSuccess=$isSuccess&failureReason=$failureReason'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }

  static Future<http.Response> getOrder(
    String orderId, {
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  static Future<List<dynamic>?> getUserOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/my-orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data;
        } else if (data is Map && data['orders'] != null) {
          return data['orders'];
        }
        return [];
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch user orders: $e');
    }
  }
}
