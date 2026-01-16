import 'package:flutter/material.dart';
import 'package:greennest/Auth/login_screen.dart';

class RouteGuard {
  /// Check if user has admin access
  /// This is a simple check - ideally you should decode JWT to verify role
  static Future<bool> isAdminUser(String token) async {
    try {
      // TODO: Implement JWT decoding to verify ADMIN role
      // For now, we'll assume token exists means admin
      return token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Guard route by checking token and admin role
  static Route<dynamic> createRoute(
    Widget Function() pageBuilder,
    String token, {
    bool requireAdmin = false,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        // Check if token exists
        if (token.isEmpty) {
          return const LoginScreen();
        }

        // If admin is required, you should verify role from token
        // For now, we trust that token holder has the required role
        return pageBuilder();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
