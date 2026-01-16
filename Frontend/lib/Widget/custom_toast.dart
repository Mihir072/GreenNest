import 'package:flutter/material.dart';
import 'package:greennest/Util/colors.dart';
import 'package:overlay_support/overlay_support.dart';

class CustomToast {
  static void show({
    required String title,
    required String message,
    required Color bgColor,
    required String iconUrl,
    Duration duration = const Duration(seconds: 3),
  }) {
    showSimpleNotification(
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getIconForTitle(title),
                  color: white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: TextStyle(
                      color: white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
      background: bgColor,
      duration: duration,
      elevation: 8,
    );
  }

  /// Success notification
  static void success({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      title: title,
      message: message,
      bgColor: const Color(0xFF4CAF50),
      iconUrl: '',
      duration: duration,
    );
  }

  /// Error notification
  static void error({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      title: title,
      message: message,
      bgColor: const Color(0xFFE53935),
      iconUrl: '',
      duration: duration,
    );
  }

  /// Warning notification
  static void warning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      title: title,
      message: message,
      bgColor: const Color(0xFFFFA726),
      iconUrl: '',
      duration: duration,
    );
  }

  /// Info notification
  static void info({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      title: title,
      message: message,
      bgColor: const Color(0xFF2196F3),
      iconUrl: '',
      duration: duration,
    );
  }

  /// Get icon based on title
  static IconData _getIconForTitle(String title) {
    if (title.toLowerCase().contains('success') ||
        title.toLowerCase().contains('added')) {
      return Icons.check_circle;
    } else if (title.toLowerCase().contains('error') ||
        title.toLowerCase().contains('failed')) {
      return Icons.error;
    } else if (title.toLowerCase().contains('warning')) {
      return Icons.warning;
    } else if (title.toLowerCase().contains('info')) {
      return Icons.info;
    } else if (title.toLowerCase().contains('order')) {
      return Icons.shopping_cart;
    } else if (title.toLowerCase().contains('favorite')) {
      return Icons.favorite;
    } else if (title.toLowerCase().contains('remove')) {
      return Icons.delete;
    }
    return Icons.notifications;
  }
}
