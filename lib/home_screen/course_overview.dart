import 'dart:convert';
import 'package:divine_soul_yoga/home_screen/list_of_days.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service/apiservice.dart';
import '../models/program_data_model.dart';

class CourseOverviewScreen extends StatefulWidget {
  final String type;

  const CourseOverviewScreen({super.key, required this.type});

  @override
  State<CourseOverviewScreen> createState() => _CourseOverviewScreenState();
}

class _CourseOverviewScreenState extends State<CourseOverviewScreen> {
  late Future<List<Program>> _coursesFuture;
  late Razorpay _razorpay;
  int amountInPaisa = 0;
  bool isTapped = false;
  String? titleCourse;
  String? courseId;

  @override
  void initState() {
    super.initState();
    // Initial loading of courses
    _loadCourses();

    _razorpay = Razorpay();

    // Setting up event handlers
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  Future<void> _loadCourses() async {
    _coursesFuture = fetchCourses(widget.type);
    setState(() {}); // Trigger a rebuild to show the updated courses
  }

  static Future<List<Program>> fetchCourses(String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
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
    String keyId = "rzp_test_t9nKkE2yOuYEkA";
    String keySecret = "fLf4GyMehyvF4gY1IyaN0NxE";

    Map<String, dynamic> body = {
      "amount": amountInPaisa,
      "currency": "INR",
      "receipt": "receipt#1",
      "payment_capture": 1
    };

    var response = await http.post(
      Uri.https("api.razorpay.com", "/v1/orders"),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}'
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print("Response Data: $responseData");
      String orderId = responseData['id'];
      openCheckout(orderId);
    } else {
      print("Something went wrong while creating order");
    }
  }

  void openCheckout(String orderid) {
    var options = {
      'key': 'rzp_test_t9nKkE2yOuYEkA',
      'amount': amountInPaisa * 100,
      'name': titleCourse,
      'description': titleCourse,
      'order_id': orderid,
    };

    try {
      _razorpay.open(options);
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
            onPressed: () {
              Navigator.pop(context);
            },
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
        content: Text('Error: ${response.message}'),
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
          style: TextStyle(
            color: Color(0xffD45700),
          ),
        ),
      ),
      body: FutureBuilder<List<Program>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
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

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListOfDays(courseId: course.id),
                      ),
                    );
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: SizedBox(
                                width: MediaQuery.sizeOf(context).width * 60,
                                child: Image.network(
                                  "https://divinesoulyoga.in/${course.image}",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.broken_image,
                                        size: 100);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              '${course.title}',
                              style: const TextStyle(
                                color: Color(0xffD45700),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            course.paid == false
                                ? Center(
                                    child: InkWell(
                                      onTap: () {
                                        courseId = course.id.toString();
                                        titleCourse = course.title;
                                        amountInPaisa =
                                            (int.parse(course.amount) * 100);

                                        createRazorpayOrder();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xffD45700),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14, horizontal: 30),
                                          child: Text(
                                            "Buy Now ₹${course.amount}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 14, horizontal: 30),
                                        child: Text(
                                          "Go to Course",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
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
}
