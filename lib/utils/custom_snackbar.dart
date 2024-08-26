import 'package:flutter/material.dart';

extension SnackBarExtension on BuildContext {
  void showCustomSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}