import 'dart:convert';
import 'package:divine_soul_yoga/src/presentation/home_screen/list_of_days.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_service/apiservice.dart';
import '../../models/program_data_model.dart';

class CourseOverviewScreen extends StatefulWidget {
  final String type;

  const CourseOverviewScreen({super.key, required this.type});

  @override
  State<CourseOverviewScreen> createState() => _CourseOverviewScreenState();
}

class _CourseOverviewScreenState extends State<CourseOverviewScreen> {
  Future<List<Program>>? _coursesFuture; // Nullable Future
  Razorpay? _razorpay; // Nullable Razorpay instance
  int amountInPaisa = 0;
  bool isTapped = false;
  String? titleCourse;
  String? courseId;
  String? userId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay(); // Initialize Razorpay immediately
    _razorpay!
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _loadUserIdAndCourses(); // Load userId and courses
  }

  Future<void> _loadUserIdAndCourses() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id'); // Store userId in state
      _coursesFuture = fetchCourses(widget.type); // Assign Future directly
    });
  }

  static Future<List<Program>> fetchCourses(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final url = 'https://divinesoulyoga.in/api/programData/$type/$userId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final coursesData = responseData['data'] as List;
        return coursesData.map((data) => Program.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to load courses: $error');
    }
  }

  Future<void> createRazorpayOrder() async {
    String keyId = dotenv.env['razorpay_key_id']!;
    String keySecret = dotenv.env['razorpay_key_secret']!;

    final body = {
      "amount": amountInPaisa,
      "currency": "INR",
      "receipt": "receipt#1",
      "payment_capture": 1
    };

    final response = await http.post(
      Uri.https("api.razorpay.com", "/v1/orders"),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print("Response Data: $responseData");
      final orderId = responseData['id'] as String;
      openCheckout(orderId);
    } else {
      print("Something went wrong while creating order");
    }
  }

  void openCheckout(String orderId) {
    String key = dotenv.env['razorpay_key_id']!;
    var options = {
      'key': key,
      'amount': amountInPaisa * 100,
      'name': titleCourse,
      'description': titleCourse,
      'order_id': orderId,
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Navigator.pop(context);
    ApiService().buyCourse(
      courseId: courseId.toString(),
      amount: amountInPaisa.toString(),
      orderId: response.orderId.toString(),
      paymentId: response.paymentId.toString(),
      paymentStatus: "true",
    );
    isTapped = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Text('Payment ID: ${response.paymentId}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ApiService().buyCourse(
      courseId: courseId.toString(),
      amount: amountInPaisa.toString(),
      orderId: response.error.toString(),
      paymentId: response.toString(),
      paymentStatus: "false",
    );
    isTapped = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: const Text('Error: Payment Failed.'),
        // content: Text('Error: ${response.message}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Courses Overview",
          style: TextStyle(color: Color(0xffD45700)),
        ),
      ),
      body: _coursesFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Program>>(
              future: _coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No courses available.'));
                } else {
                  final courses = snapshot.data!;
                  return ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return GestureDetector(
                        onTap: () {
                          print(course.id);
                          if (userId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ListOfDays(
                                  userid: userId!,
                                  courseId: course.id,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'User ID not found. Please log in again.'),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            bottom: 16,
                          ),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: SizedBox(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.9,
                                      child: Image.network(
                                        "https://divinesoulyoga.in/${course.image}",
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.broken_image,
                                              size: 100);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    course.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xffD45700),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
    );
  }

  @override
  void dispose() {
    _razorpay?.clear(); // Safely clear Razorpay instance if it exists
    super.dispose();
  }
}
