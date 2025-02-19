// import 'package:divine_soul_yoga/get_started/get_started.dart';
// import 'package:divine_soul_yoga/login/login.dart';
// import 'package:flutter/material.dart';

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Future.delayed(Duration(seconds: 5), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//             builder: (context) =>
//                 GetStarted()), // Replace with your main screen
//       );
//     });
//     var screenHeight = MediaQuery.of(context).size.height;
//     var screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             height: screenHeight,
//             width: screenWidth,
//             child: Image.asset(
//               "assets/splashimage/Splash.png",
//               fit:
//                   BoxFit.cover, // Ensures the image covers the entire container
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
