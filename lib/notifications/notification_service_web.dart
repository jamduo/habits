import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  bool _initialized = false;

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();


  Future<void> init() async {
    // Initialize the manager and channels.
    _initialized = true;
  }

  bool get isInitialized {
    return _initialized;
  }

  Future<void> cancelNotification({ required int id }) {
    if (!_initialized) throw new Exception("Notification Service is not initialized yet.");
    return Future.value();
  }

  Future<void> cancelAllNotifications() {
    if (!_initialized) throw new Exception("Notification Service is not initialized yet.");
    return Future.value();
  }

  Future<bool> sendNotification({ required int id }) {
    if (!_initialized) throw new Exception("Notification Service is not initialized yet.");
    return Future.value(true);
  }

  Future selectNotification(String? payload) async {
    // Handle notification tapped logic here
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }
}