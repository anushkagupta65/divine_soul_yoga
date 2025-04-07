import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  // Android initialization settings
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // Initialize the plugin
  bool? initialized = await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print('Notification received: ${response.payload}');
    },
  );

  print('Notifications initialized: $initialized');

  // Create the WorkManager debug channel with importance none
  const AndroidNotificationChannel wmChannel = AndroidNotificationChannel(
    'workmanager_background_channel_work_manager_generated',
    'WorkManager background channel',
    importance: Importance.none,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(wmChannel);

  // Request notification permission for Android 13 and above
  if (await Permission.notification.isDenied) {
    PermissionStatus status = await Permission.notification.request();
    print('Notification permission status: $status');
    if (status.isDenied) {
      print('Notification permission denied. Cannot show notifications.');
      if (status.isPermanentlyDenied) {
        print(
            'Notification permission permanently denied. Opening app settings.');
        await openAppSettings();
      }
      return;
    }
  }
}

Future<void> showNotification(String title, String body, String type) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'subscription_channel',
    'Subscription Reminders',
    importance: Importance.max,
    priority: Priority.high,
    channelDescription: 'Notifications for subscription expiration reminders',
    showWhen: true,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Use a unique ID for each notification type to avoid overwriting
  int notificationId = type == 'reminder' ? 0 : 1;

  print(
      'Attempting to show notification: $title - $body (Type: $type, ID: $notificationId)');

  try {
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
    );
    print('Notification shown successfully: $title - $body');
  } catch (e) {
    print('Error showing notification: $e');
  }
}
