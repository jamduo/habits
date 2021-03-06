import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AwesomeNotifications _notificationManager = AwesomeNotifications();

  static final notificationChannels = [
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic Notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white
        )
  ];
  static final defaultChannel = notificationChannels[0];

  bool _initialized = false;

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();


  Future<void> init() async {
    // Initialize the manager and channels.
    await _notificationManager.initialize(
      null /* 'resource://drawable/res_app_icon' */,
      notificationChannels
    );
    // _notificationManager.setChannel(defaultChannel);

    // Request Notifications Permissions
    await _notificationManager.isNotificationAllowed().then((isAllowed) async { if (!isAllowed) { await _notificationManager.requestPermissionToSendNotifications(); } });

    // final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('temp');  
    // final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);  
    // await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: selectNotification);

    _initialized = true;
  }

  bool get isInitialized {
    return _initialized;
  }

  Future<void> cancelNotification({ required int id }) {
    if (!_initialized) throw new Exception("Notification Service is not initialized yet.");
    return _notificationManager.cancelSchedule(id);
  }

  Future<void> cancelAllNotifications() {
    if (!_initialized) throw new Exception("Notification Service is not initialized yet.");
    return _notificationManager.cancelAllSchedules();
  }

  Future<bool> sendNotification({ required int id }) {
    if (!_initialized) throw new Exception("Notification Service is not initialized yet.");
    
    NotificationContent content = NotificationContent(
      id: id,
      channelKey: defaultChannel.channelKey,
      title: "Test",
      body: "Schedule 2",
      displayOnForeground: true,
      displayOnBackground: true,
    );

    
    NotificationSchedule schedule = NotificationInterval(interval: 10, allowWhileIdle: true, repeats: true);
    // NotificationSchedule schedule = NotificationCalendar(second: 1, allowWhileIdle: true, repeats: true);

    return _notificationManager.createNotification(
      content: content,
      schedule: schedule,
    );
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