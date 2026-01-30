import 'package:flutter/material.dart';
import 'package:buck/components/notification_banner.dart';

class NotificationService {
  static OverlayEntry? _currentEntry;
  static bool _isShowing = false;

  static void show(
    BuildContext context, {
    required String message,
    NotificationType type = NotificationType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Dismiss current notification if showing
    if (_isShowing) {
      dismiss();
      // Wait a bit before showing the new one
      Future.delayed(const Duration(milliseconds: 200), () {
        _showNotification(context, message, type, duration);
      });
    } else {
      _showNotification(context, message, type, duration);
    }
  }

  static void _showNotification(
    BuildContext context,
    String message,
    NotificationType type,
    Duration duration,
  ) {
    _isShowing = true;
    final overlay = Overlay.of(context);

    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: NotificationBanner(
            message: message,
            type: type,
            duration: duration,
            onDismissed: () {
              dismiss();
            },
          ),
        ),
      ),
    );

    overlay.insert(_currentEntry!);
  }

  static void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
    _isShowing = false;
  }

  // Convenience methods
  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: NotificationType.success);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, type: NotificationType.info);
  }

  static void showWarning(BuildContext context, String message) {
    show(context, message: message, type: NotificationType.warning);
  }

  static void showError(BuildContext context, String message) {
    show(context, message: message, type: NotificationType.error);
  }
}
