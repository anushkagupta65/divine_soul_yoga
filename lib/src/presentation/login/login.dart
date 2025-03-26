import 'dart:async';
import 'package:divine_soul_yoga/src/presentation/home_screen/home_screen.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/profile.dart';
import 'package:divine_soul_yoga/src/models/usermodel.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _nameController = TextEditingController();
  bool _showNameField = false;

  Future<void> registerNumber(BuildContext context) async {
    final mobile = _controller.text.trim();
    final url = Uri.parse('http://68.183.83.189/api/login');

    try {
      print("Sending request to $url with body: {'mobile': '$mobile'}");

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'mobile': mobile}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException("Request timed out"),
          );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Login successful: ${data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful.")),
        );

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(60)),
          ),
          builder: (context) {
            return BottomSheetContent(initialNumber: mobile);
          },
        );
      } else if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("Account created successfully: ${data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully.")),
        );

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(60)),
          ),
          builder: (context) {
            return BottomSheetContent(initialNumber: mobile);
          },
        );
      } else {
        final data = jsonDecode(response.body);
        print("Error: ${data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${data['message']}")),
        );
      }
    } catch (e) {
      String errorMessage;
      if (e is http.ClientException) {
        errorMessage = "Network error: Unable to connect to the server.";
      } else if (e is FormatException) {
        errorMessage = "Invalid response from server.";
      } else if (e is TimeoutException) {
        errorMessage = "Request timed out. Please check your connection.";
      } else {
        errorMessage = "An unexpected error occurred: $e";
      }

      print("Exception details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              SizedBox(
                height: screenHeight,
                width: screenWidth,
                child: Image.asset(
                  "assets/images/login.png",
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 135),
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      'Let\'s Start',
                      style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffD45700)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 0.20,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 45, right: 28),
                    child: const Text(
                      "Enter Your Mobile Number",
                      style: TextStyle(
                          color: Color(0xff344033),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 526, left: 28),
                child: Text(
                  ' Mobile Number',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 540),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _controller,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          counterText: "",
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(top: 11.0, left: 10),
                            child: Text(
                              "+91",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          hintText: 'Enter your mobile number',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 83, 81, 81),
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(35.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 124, 122, 122),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(120.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 120, 117, 117),
                            ),
                          ),
                          labelStyle: const TextStyle(fontSize: 16),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length != 10) {
                            return 'Please enter a valid mobile number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 700),
                child: Align(
                  child: SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          registerNumber(context);

                          print('Get OTP button pressed');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffD45700),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Get OTP',
                          style: TextStyle(
                              color: Color.fromRGBO(236, 243, 235, 1),
                              fontSize: 25)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomSheetContent extends StatefulWidget {
  final String initialNumber;

  const BottomSheetContent({
    super.key,
    required this.initialNumber,
  });

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController pinController = TextEditingController();

  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  UserProfile? userProfile;

  String getOtp() {
    return pinController.text;
  }

  final defaultPinTheme = PinTheme(
    width: 54,
    height: 54,
    margin: const EdgeInsets.all(10),
    textStyle: const TextStyle(
      fontSize: 22,
      color: Color.fromRGBO(30, 60, 87, 1),
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xffD45700), width: 2),
    ),
  );

  void _validateAndSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      String otp = getOtp();
      bool? otpValid = await verifyOtp();
      print('OTP response_${otpValid}');
      if (otpValid!) {
        if (userProfile != null) {
          if (userProfile!.name != null ||
              userProfile!.dob != null ||
              userProfile!.city != null ||
              userProfile!.state != null ||
              userProfile!.address != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const Profile(index: "0")),
            );
          }
        }
      }
    }
  }

  Future<bool?> verifyOtp() async {
    final url = Uri.parse('http://68.183.83.189/api/verify-otp');
    String otp = getOtp();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'mobile': widget.initialNumber, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        Navigator.of(context).pop();
        final data = jsonDecode(response.body);
        print("NAme123456${data["user"]["name"]}");
        prefs.setString("user_id", data["user"]["id"].toString());
        prefs.setString("registerMobile", data["user"]["mobile"].toString());
        if (data["user"]["name"].toString() == 'null') {
          prefs.setString("user_id", data["user"]["id"].toString());
          prefs.setBool("name", false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Profile(index: "0")),
          );
          return true;
        } else {
          print("UserName1234: ${data["user"]["name"]}");
          prefs.setBool("name", true);
          prefs.setString("user_id", data["user"]["id"].toString());
          prefs.setString("name", data["user"]["name"]);
          prefs.setString("mobile", data["user"]["mobile"].toString());
          prefs.setString("email", data["user"]["email"].toString());
          prefs.setString("dob", data["user"]["dob"].toString());
          prefs.setString("city", data["user"]["city"].toString());
          prefs.setString("state", data["user"]["state"].toString());
          prefs.setString("address", data["user"]["address"].toString());
          print("NameSaved in shared pref${prefs.getString("name")}");
          print("Id in shared pref${prefs.getString("user_id")}");

          userProfile = UserProfile.fromJson(data['user']);
          return true;
        }
      } else {
        print("Verification failed: ${response.body}");
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(jsonDecode(response.body)['message']),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xffD45700),
        ));
        return false;
      }
    } catch (e) {
      print("An error occurred: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(border: Border()),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          top: 16.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter OTP',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 32),
              Pinput(
                length: 4,
                controller: pinController,
                defaultPinTheme: defaultPinTheme,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD45700),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    pinController.dispose();
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
