import 'package:divine_soul_yoga/home_screen/home_screen.dart';
import 'package:divine_soul_yoga/login/login.dart';
import 'package:divine_soul_yoga/models/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  void loginCheck() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: screenHeight,
            width: screenWidth,
            child: Image.asset(
              "assets/images/getstarted.png",
              fit:
                  BoxFit.cover, // Ensures the image covers the entire container
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 100),
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  'Welcome',
                  style: TextStyle(
                      fontSize: 55,
                      fontWeight: FontWeight.w400,
                      color: Color(0xffD45700)),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 1),
              Container(
                margin: EdgeInsets.all(30),
                padding: const EdgeInsets.only(right: 50),
                child: Text(
                  "we’re glad that you are here",
                  style: TextStyle(
                      color: Color(0xff344033),
                      fontSize: 22,
                      fontWeight: FontWeight.w300),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () async {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    int? userId = pref.getInt('id');

                    print("userId:   **************88   $userId");
                    if (userId != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    }

                    // Handle button press
                    print('Lets get started button pressed');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color(0xffD45700), // Background color of the button
                    foregroundColor: Colors.white, // Text color of the button
                    padding: EdgeInsets.symmetric(vertical: 9, horizontal: 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20), // Optional: To make the button rounded
                    ),
                  ),
                  child: Text(
                    'Lets get started',
                    style: TextStyle(
                        color: Color.fromRGBO(236, 243, 235, 1),
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
