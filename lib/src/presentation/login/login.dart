import 'dart:async';
import 'package:divine_soul_yoga/src/presentation/home_screen/home_screen.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/profile.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> registerNumber(BuildContext context) async {
    print("is this working? in registerNumber");
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final mobile = _controller.text.trim();
    const url = 'http://68.183.83.189/api/login';

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'mobile': mobile}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Result in registerNumber ${response.body}");
        await _showOtpBottomSheet(context, mobile);
      } else {
        // No SnackBar, just log for debugging
        print("Failed to send OTP: ${jsonDecode(response.body)['message']}");
      }
    } catch (e) {
      print("Error in registerNumber: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showOtpBottomSheet(BuildContext context, String mobile) async {
    print("is this working? in _showOtpBottomSheet");
    print("mobile number in _showOtpBottomSheet $mobile");
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(60)),
      ),
      builder: (_) => BottomSheetContent(initialNumber: mobile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              SizedBox(
                height: screenHeight,
                width: screenWidth,
                child:
                    Image.asset("assets/images/login.png", fit: BoxFit.cover),
              ),
              const Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 135),
                    child: Text(
                      'Let\'s Start',
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffD45700),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 0.20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      "Enter Your Mobile Number",
                      style: TextStyle(
                        color: Color(0xff344033),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 526, left: 28),
                child: Text(
                  'Mobile Number',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 540),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  child: TextFormField(
                    controller: _controller,
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      counterText: "",
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(top: 11.0, left: 10),
                        child: Text("+91", style: TextStyle(fontSize: 20)),
                      ),
                      hintText: 'Enter your mobile number',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 83, 81, 81), width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35.0),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 124, 122, 122)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(120.0),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 120, 117, 117)),
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty || value.length != 10
                            ? 'Please enter a valid mobile number'
                            : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 700),
                child: Align(
                  child: SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : () => registerNumber(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffD45700),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 22),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Get OTP',
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class BottomSheetContent extends StatefulWidget {
  final String initialNumber;

  const BottomSheetContent({super.key, required this.initialNumber});

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController pinController = TextEditingController();
  bool _isLoading = false;

  final defaultPinTheme = const PinTheme(
    width: 54,
    height: 54,
    margin: EdgeInsets.all(10),
    textStyle: TextStyle(fontSize: 22, color: Color.fromRGBO(30, 60, 87, 1)),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      border:
          Border.fromBorderSide(BorderSide(color: Color(0xffD45700), width: 2)),
    ),
  );

  Future<void> _validateAndSubmit() async {
    print("OTP: ${pinController.text}");
    print("is this working?");
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final otpValid = await verifyOtp();
      if (otpValid == true) {
        // Close the bottom sheet first
        Navigator.pop(context);
      } else {
        print("OTP verification failed");
      }
    } catch (e) {
      print("Error in _validateAndSubmit: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool?> verifyOtp() async {
    print("is this working? in verifyOtp");
    const url = 'http://68.183.83.189/api/verify-otp';
    final otp = pinController.text;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': widget.initialNumber, 'otp': otp}),
      );

      final data = jsonDecode(response.body);
      print("status code in verifyOtp ${response.statusCode}");
      if (response.statusCode == 200) {
        print("Result in verifyOtp ${data['success']}");
        print("Result in verifyOtp ${data['message']}");
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("user_id", data["user"]["id"].toString());
        prefs.setString("registerMobile", data["user"]["mobile"].toString());

        // Perform navigation after bottom sheet is closed
        if (data["user"]["name"] == null) {
          prefs.setBool("name", false);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const Profile(index: "0")),
            );
          });
        } else {
          prefs.setBool("name", true);
          prefs.setString("name", data["user"]["name"]);
          prefs.setString("mobile", data["user"]["mobile"].toString());
          prefs.setString("email", data["user"]["email"].toString());
          prefs.setString("dob", data["user"]["dob"].toString());
          prefs.setString("city", data["user"]["city"].toString());
          prefs.setString("state", data["user"]["state"].toString());
          prefs.setString("address", data["user"]["address"].toString());
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          });
        }
        return true;
      } else {
        print("Verification failed: ${data['message']}");
        return false;
      }
    } catch (e) {
      print("Error in verifyOtp: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
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
              const Text('Enter OTP',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400)),
              const SizedBox(height: 32),
              Pinput(
                length: 4,
                controller: pinController,
                defaultPinTheme: defaultPinTheme,
                autofocus: false,
                validator: (value) =>
                    value!.length != 4 ? 'Enter a 4-digit OTP' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD45700),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login',
                        style: TextStyle(
                            fontSize: 23, fontWeight: FontWeight.w400)),
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
    super.dispose();
  }
}
