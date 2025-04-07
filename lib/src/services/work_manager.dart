import 'package:divine_soul_yoga/src/services/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const String expirationCheckTask = "checkSubscriptionExpiration";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask(
    (task, inputData) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? endDateStr = prefs.getString('subscription_end_date');

      if (endDateStr == null) {
        return Future.value(false);
      }

      DateTime endDate = DateTime.parse(endDateStr);
      DateTime now = DateTime.now();

      DateTime reminderDate = endDate.subtract(const Duration(days: 3));
      bool isReminderDay = now.day == reminderDate.day &&
          now.month == reminderDate.month &&
          now.year == reminderDate.year;

      bool isExpiryDay = now.day == endDate.day &&
          now.month == endDate.month &&
          now.year == endDate.year;

      if (isReminderDay) {
        bool canShowNotification =
            await _canShowNotification(prefs, 'reminder');
        if (canShowNotification) {
          await initializeNotifications();
          await showNotification(
            'Subscription Expiring Soon',
            'Your subscription is set to expire on ${endDate.toString().substring(0, 10)}! Don’t miss out.\nRenew now to keep enjoying uninterrupted access!',
            'reminder',
          );
          await _updateLastNotificationTime(prefs, 'reminder');
        }
      }

      if (isExpiryDay) {
        DateTime expiryTime = endDate;
        DateTime notificationTime =
            expiryTime.subtract(const Duration(hours: 2));

        Duration timeDifference = now.difference(notificationTime);
        bool isWithinNotificationWindow = timeDifference.inMinutes.abs() <= 15;

        if (isWithinNotificationWindow) {
          bool canShowNotification =
              await _canShowNotification(prefs, 'expiry');
          if (canShowNotification) {
            await initializeNotifications();
            await showNotification(
              'Subscription Expiring Today',
              'Your subscription is ending today at ${endDate.hour}:${endDate.minute.toString().padLeft(2, '0')}. Please renew it!',
              'expiry',
            );
            await _updateLastNotificationTime(prefs, 'expiry');
          }
        }
      }

      return Future.value(false);
    },
  );
}

Future<bool> _canShowNotification(SharedPreferences prefs, String type) async {
  String lastNotificationKey = 'last_notification_$type';
  String lastNotificationDateKey = 'last_notification_date_$type';

  int? lastNotificationTimestamp = prefs.getInt(lastNotificationKey);
  String? lastNotificationDate = prefs.getString(lastNotificationDateKey);

  DateTime now = DateTime.now();
  String currentDate = now.toString().substring(0, 10);

  if (lastNotificationDate == currentDate) {
    return false;
  }

  if (lastNotificationTimestamp != null) {
    DateTime lastNotificationTime =
        DateTime.fromMillisecondsSinceEpoch(lastNotificationTimestamp);
    Duration timeSinceLastNotification = now.difference(lastNotificationTime);
    if (timeSinceLastNotification.inHours < 6) {
      return false;
    }
  }

  return true;
}

Future<void> _updateLastNotificationTime(
    SharedPreferences prefs, String type) async {
  String lastNotificationKey = 'last_notification_$type';
  String lastNotificationDateKey = 'last_notification_date_$type';

  DateTime now = DateTime.now();
  await prefs.setInt(lastNotificationKey, now.millisecondsSinceEpoch);
  await prefs.setString(
      lastNotificationDateKey, now.toString().substring(0, 10));
}

Future<void> scheduleExpirationCheck() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // Suppress WorkManager notifications by setting IMPORTANCE_MIN
  Workmanager().registerPeriodicTask(
    "1",
    expirationCheckTask,
    frequency: const Duration(hours: 1),
    initialDelay: const Duration(minutes: 1),
    constraints: Constraints(
      networkType: NetworkType.not_required,
    ),
    existingWorkPolicy: ExistingWorkPolicy.replace,
    backoffPolicy: BackoffPolicy.exponential,
    backoffPolicyDelay: const Duration(minutes: 1),
  );
}
