import 'package:divine_soul_yoga/src/services/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const String expirationCheckTask = "checkSubscriptionExpiration";

void callbackDispatcher() {
  Workmanager().executeTask(
    (task, inputData) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? endDateStr = prefs.getString('subscription_end_date');

      if (endDateStr != null) {
        DateTime endDate = DateTime.parse(endDateStr);
        DateTime now = DateTime.now();
        DateTime reminderDate = endDate.subtract(const Duration(days: 3));

        if (now.day == reminderDate.day &&
            now.month == reminderDate.month &&
            now.year == reminderDate.year) {
          await initializeNotifications();
          await showNotification(
            'Subscription Expiring Soon',
            'Your subscription will expire on $endDateStr. Please renew it!',
          );
        }
      }
      return Future.value(true);
    },
  );
}

Future<void> scheduleExpirationCheck() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await Workmanager().registerPeriodicTask(
    "1",
    expirationCheckTask,
    frequency: const Duration(days: 1),
    initialDelay: const Duration(minutes: 1),
    constraints: Constraints(
      networkType: NetworkType.not_required,
    ),
  );
}
