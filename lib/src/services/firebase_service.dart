import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission");
    } else {
      print("User denied permission");
    }

    // Get FCM Token
    String? token = await messaging.getToken();
    print("FCM Token: $token");

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received a message: ${message.notification?.title}");
    });

    // Background message handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message clicked!");
    });
  }
}
