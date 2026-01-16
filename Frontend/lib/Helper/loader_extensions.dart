import 'package:flutter/material.dart';

extension LoaderExtension on BuildContext {
  void showLoader({String? message}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message, style: const TextStyle(color: Colors.white)),
            ],
          ],
        ),
      ),
    );
  }

  void hideLoader() {
    Navigator.of(this, rootNavigator: true).pop();
  }
}
