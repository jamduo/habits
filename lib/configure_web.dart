import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'notifications/notification_service.dart' if (dart.library.html) 'notifications/notification_service_web.dart';

Future<void> configureApp() async {
  setUrlStrategy(PathUrlStrategy());
  await NotificationService().init();
}
