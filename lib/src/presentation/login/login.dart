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
  // Login({super.key});
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _nameController = TextEditingController();
  bool _showNameField = false;

  // Future<void> registerNumber(
  //     String name, String number, BuildContext context) async {
  //   final url = Uri.parse(
  //       'http://68.183.83.189/api/login'); // Replace with your API URL
  //   // print('number: ************************ $number');

  //   try {
  //     // Prepare the request body
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(
  //           {'mobile': number!, "email": "$number@gmail.com", 'name': name!}),
  //     );

  //     // Check the response status
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       print("Registration successful: ${data['message']}");
  //       showModalBottomSheet(
  //         context: context,
  //         isScrollControlled: true,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.vertical(
  //             top: Radius.circular(60),
  //           ),
  //         ),
  //         builder: (context) {
  //           return BottomSheetContent(
  //             initialNumber: _controller.text.trim(),
  //           );
  //         },
  //       );
  //     } else {
  //       print("Registration failed: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("An error occurred: $e");
  //   }
  // }

  // Future<void> registerNumber(BuildContext context) async {
  //   final mobile = _controller.text.trim();
  //   final name = _nameController.text.trim();
  //   final url = Uri.parse('http://68.183.83.189/api/login');

  //   try {
  //     // Create request body based on whether name is provided
  //     // final requestBody = _showNameField
  //     //     ? {'mobile': mobile, 'email': "$mobile@gmail.com", 'name': name}
  //     //     : {'mobile': mobile, 'email': "$mobile@gmail.com"};

  //     final requestBody = {'mobile': mobile, 'email': "$mobile@gmail.com"};

  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(requestBody),
  //     );

  //     if (response.statusCode == 200) {
  //       // OTP sent successfully
  //       final data = jsonDecode(response.body);
  //       print("OTP sent successfully: ${data['message']}");
  //       setState(() {
  //         _showNameField = false;
  //       });
  //       // ScaffoldMessenger.of(context).showSnackBar(
  //       //   SnackBar(
  //       //     content: Text("OTP sent successfully."),
  //       //     behavior: SnackBarBehavior.floating,
  //       //   ),
  //       // );
  //       showModalBottomSheet(
  //         context: context,
  //         isScrollControlled: true,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.vertical(
  //             top: Radius.circular(60),
  //           ),
  //         ),
  //         builder: (context) {
  //           return BottomSheetContent(
  //             initialNumber: _controller.text.trim(),
  //           );
  //         },
  //       );
  //     } else if (response.statusCode == 404 && !_showNameField) {
  //       // Number not found, show name field for account creation
  //       setState(() {
  //         _showNameField = true;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(jsonDecode(response.body)['message'])),
  //       );
  //     } else if (response.statusCode == 200 && _showNameField) {
  //       // Account created successfully
  //       final data = jsonDecode(response.body);
  //       print("Account created successfully: ${data['message']}");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Account created successfully.")),
  //       );
  //     } else {
  //       print("Error: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("An error occurred: $e");
  //   }
  // }

  Future<void> registerNumber(BuildContext context) async {
    final mobile = _controller.text.trim();
    final url = Uri.parse('http://68.183.83.189/api/login');

    try {
      final requestBody = {
        'mobile': mobile,
        //'email': "$mobile@gmail.com"
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Login successful
        final data = jsonDecode(response.body);
        print("Login successful: ${data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful.")),
        );

        // Open the OTP verification modal
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(60),
            ),
          ),
          builder: (context) {
            return BottomSheetContent(
              initialNumber: _controller.text.trim(),
            );
          },
        );
      } else if (response.statusCode == 201) {
        // Account created successfully
        final data = jsonDecode(response.body);
        print("Account created successfully: ${data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account created successfully.")),
        );

        // Open the OTP verification modal
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(60),
            ),
          ),
          builder: (context) {
            return BottomSheetContent(
              initialNumber: _controller.text.trim(),
            );
          },
        );
      } else {
        // Handle other status codes
        final data = jsonDecode(response.body);
        print("Error: ${data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } catch (e) {
      // Handle unexpected exceptions
      print("An error occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred.")),
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
          child: Stack(children: [
            Container(
              height: screenHeight,
              width: screenWidth,
              child: Image.asset(
                "assets/images/login.png",
                fit: BoxFit
                    .cover, // Ensures the image covers the entire container
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
                    // Name field

                    // Space between fields

                    // Mobile number field
                    TextFormField(
                      controller: _controller,
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        counterText: "",
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(top: 11.0, left: 10),
                          child: const Text(
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
                    // const SizedBox(height: 20),
                    // if (_showNameField)
                    //   TextFormField(
                    //     controller: _nameController, // Controller for name
                    //     decoration: InputDecoration(
                    //       hintText: 'Enter your name',
                    //       filled: true,
                    //       fillColor: Colors.white,
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(20.0),
                    //         borderSide: const BorderSide(
                    //           color: Color.fromARGB(255, 83, 81, 81),
                    //           width: 1.0,
                    //         ),
                    //       ),
                    //       enabledBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(35.0),
                    //         borderSide: const BorderSide(
                    //           color: Color.fromARGB(255, 124, 122, 122),
                    //         ),
                    //       ),
                    //       focusedBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(120.0),
                    //         borderSide: const BorderSide(
                    //           color: Color.fromARGB(255, 120, 117, 117),
                    //         ),
                    //       ),
                    //       labelStyle: const TextStyle(fontSize: 16),
                    //     ),
                    //     validator: (value) {
                    //       if (value == null || value.isEmpty) {
                    //         return 'Please enter your name';
                    //       }
                    //       return null;
                    //     },
                    //   ),
                  ],
                ),
              ),
            ),

            // TextField(),
            Padding(
                padding: const EdgeInsets.only(top: 700),
                child: Align(
                  child: Container(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          registerNumber(context);

                          // Handle button press
                          print('Get OTP button pressed');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                            0xffD45700), // Background color of the button
                        foregroundColor:
                            Colors.white, // Text color of the button
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              30), // Optional: To make the button rounded
                        ),
                      ),
                      child: const Text('Get OTP',
                          style: TextStyle(
                              color: Color.fromRGBO(236, 243, 235, 1),
                              fontSize: 25)),
                    ),
                  ),
                )),
          ]),
        ),
      ),
    );
  }
}

class BottomSheetContent extends StatefulWidget {
  final String initialNumber;
  BottomSheetContent({required this.initialNumber});
  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  // final List<TextEditingController> _otpControllers =
  //     List.generate(4, (_) => TextEditingController());
  final TextEditingController pinController = TextEditingController();
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  UserProfile? userProfile;
  // Function to get the entered OTP
  String getOtp() {
    // return _otpControllers.map((controller) => controller.text).join();
    return pinController.text;
  }

  final defaultPinTheme = PinTheme(
    width: 54,
    height: 54,
    margin: EdgeInsets.all(10),
    textStyle: const TextStyle(
      fontSize: 22,
      color: Color.fromRGBO(30, 60, 87, 1),
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Color(0xffD45700), width: 2),
    ),
  );

  // Function to validate the OTP
  void _validateAndSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      String otp = getOtp();
      bool? otpValid = await verifyOtp();
      print('OTP response_${otpValid}');
      // if (otp == "1234") {
      if (otpValid!) {
        // Example OTP validation
        if (userProfile != null) {
          if (userProfile!.name != null ||
              userProfile!.dob != null ||
              userProfile!.city != null ||
              userProfile!.state != null ||
              userProfile!.address != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Profile(index: "0")),
            );
          }
        }
      }
      // else {
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(builder: (context) => Profile()),
      //     );
      //   }
      // else {
      //   ScaffoldMessenger.of(context)
      //       .showSnackBar(SnackBar(content: Text('Invalid OTP')));
      // }
    }
  }

  // Future<bool> verifyOtp() async {
  //   // SharedPreferences pref = await SharedPreferences.getInstance();
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   String otp = getOtp();
  //   final url = Uri.parse(
  //       'http://68.183.83.189/api/verify-otp'); // Replace with your API URL

  //   try {
  //     // Prepare the request body
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({'mobile': widget.initialNumber, "otp": otp}),
  //     );

  //     // Check the response status
  //     if (response.statusCode == 200) {
  //       Navigator.of(context).pop();
  //       final data = jsonDecode(response.body);
  //       print("Verify Succesfull: ${data}");
  //       print("Verify Succesfull: ${data['user']}");
  //       print("Verify Succesfull: ${data['user']['id'] ?? ''}");
  //       print("Verify Succesfull: ${data['user']['name'] ?? ''}");
  //       print("Verify Succesfull: ${data['user']['email'] ?? ''}");
  //       // print("Verify Succesfull: ${data['user']['mobile'] ?? 0}");
  //       setState(() {
  //         pref.setInt('id', data!['user']['id'] ?? '');
  //         pref.setString('name', data!['user']['name'] ?? '');
  //         pref.setString('email', data!['user']['email'] ?? '');
  //         pref.setString('mobile', data!['user']['mobile'] ?? '');
  //         pref.setString('city', data!['user']['city'] ?? '');
  //         pref.setString('state', data!['user']['state'] ?? '');
  //         pref.setString('address', data!['user']['address'] ?? '');
  //       });
  //       return true;
  //     } else {
  //       print("Verification failed: ${response.body}");
  //       Navigator.of(context).pop();
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text(jsonDecode(response.body)['message']),
  //         behavior: SnackBarBehavior.floating,
  //         backgroundColor: const Color(0xffD45700),
  //       ));
  //       return false;
  //     }
  //   } catch (e) {
  //     print("An error occurred: $e");
  //     return false;
  //   }
  // }

  Future<bool?> verifyOtp() async {
    final url = Uri.parse(
        'http://68.183.83.189/api/verify-otp'); // Replace with your API URL
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
            MaterialPageRoute(builder: (context) => Profile(index: "0")),
          );
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
          // Create a UserProfile instance
          userProfile = await UserProfile.fromJson(data['user']);

          // Use the userProfile instance as needed in your app
          // For example, you can pass it to another screen or store it in a state management solution

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
      decoration: BoxDecoration(border: Border()),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom +
              16.0, // Adjust for keyboard
          top: 16.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Enter OTP',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
              ),

              SizedBox(height: 32),

              // 4-Digit OTP Input
              Pinput(
                length: 4,
                controller: pinController,
                defaultPinTheme: defaultPinTheme,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: List.generate(4, (index) {
              //     return SizedBox(
              //       width: 52,
              //       height: 50,
              //       child: TextFormField(
              //         // controller: _otpControllers[index],
              //         focusNode: _focusNodes[index],
              //         keyboardType: TextInputType.number,
              //         textAlign: TextAlign.center,
              //         maxLength: 1,
              //         decoration: InputDecoration(
              //           counterText: '',
              //           border: OutlineInputBorder(),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide:
              //                 BorderSide(color: Color(0xffD45700), width: 2),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide:
              //                 BorderSide(color: Color(0xffD45700), width: 2),
              //           ),
              //         ),
              //         onChanged: (value) {
              //           if (value.isNotEmpty && index < 3) {
              //             FocusScope.of(context).requestFocus(
              //                 _focusNodes[index + 1]); // Move to next field
              //           }
              //           if (value.isEmpty && index > 0) {
              //             FocusScope.of(context).requestFocus(_focusNodes[
              //                 index -
              //                     1]); // Move to previous field on backspace
              //           }
              //         },
              //         validator: (value) {
              //           if (value == null ||
              //               value.isEmpty ||
              //               !RegExp(r'^[0-9]$').hasMatch(value)) {
              //             return ''; // You can return a message or keep it blank for minimal visual disruption
              //           }
              //           return null;
              //         },
              //       ),
              //     );
              //   }),
              // ),

              SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: _validateAndSubmit,
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w400),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffD45700),
                  foregroundColor: Colors.white, // Text color of the button
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  minimumSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
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
    // Dispose of the controllers and focus nodes when done
    // for (var controller in _otpControllers) {
    //   controller.dispose();
    // }
    pinController.dispose();
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
