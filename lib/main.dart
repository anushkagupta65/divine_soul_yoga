import 'dart:developer';
import 'package:divine_soul_yoga/src/presentation/home_screen/home_screen.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/profile.dart';
import 'package:divine_soul_yoga/src/presentation/login/login.dart';
import 'package:divine_soul_yoga/src/provider/userprovider.dart';
import 'package:divine_soul_yoga/src/services/firebase_service.dart';
import 'package:divine_soul_yoga/src/services/work_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? endDate = prefs.getString('subscription_end_date');
  if (endDate != null) {
    await scheduleExpirationCheck();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Userprovider()),
      ],
      child: await initializeApp(),
    ),
  );
  await dotenv.load(fileName: ".env");
}

Future<Widget> determineFirstScreen() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");
    String? name = prefs.getString("name");
    log("User ID: $userId, Name: $name");

    if (userId != null && userId.isNotEmpty) {
      if (name == null || name.isEmpty) {
        return Profile(
          index: "0",
          userId: userId,
        );
      } else {
        return HomeScreen(
          userId: userId,
        );
      }
    } else {
      return const Login();
    }
  } catch (e) {
    log("Error in determineFirstScreen: $e");
    return const Login();
  }
}

Future<Widget> initializeApp() async {
  Widget firstScreen = await determineFirstScreen();
  return MyApp(firstScreen: firstScreen);
}

class MyApp extends StatelessWidget {
  final Widget firstScreen;

  const MyApp({super.key, required this.firstScreen});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Divine Soul Yoga',
        theme: ThemeData(
          fontFamily: 'Gotu',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: firstScreen,
      ),
    );
  }
}
