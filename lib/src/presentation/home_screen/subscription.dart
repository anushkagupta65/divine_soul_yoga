import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../provider/userprovider.dart';
import 'home_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool isSubscribed = false;
  List<dynamic> subscriptions = [];
  bool isLoading = true;
  late Razorpay _razorpay;
  int amountInPaisa = 0;
  String subsId = '';
  String selectedName = '';
  String selectedDescription = '';
  int subid = 0;
  bool isTapped = false;

  @override
  void initState() {
    super.initState();
    fetchSubscriptions();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> createRazorpayOrder() async {
    debugPrint("\n\ncreateRazorpayOrder() called...\n\n");

    if (subsId.isEmpty) {
      debugPrint("\n\nError: Subscription ID is empty. Cannot proceed.\n\n");
      return;
    }

    String keyId = dotenv.env['razorpay_live_key_id'] ?? '';
    String keySecret = dotenv.env['razorpay_live_key_secret'] ?? '';

    if (keyId.isEmpty || keySecret.isEmpty) {
      debugPrint("\n\nError: Razorpay API keys are missing.\n\n");
      return;
    }

    Map<String, dynamic> body = {
      "amount": amountInPaisa,
      "currency": "INR",
      "receipt": "receipt#1",
      "payment_capture": 1
    };

    try {
      var response = await http.post(
        Uri.https("api.razorpay.com", "/v1/orders"),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}'
        },
      );

      debugPrint("\n\nAPI Response: ${response.body}\n\n");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String orderId = responseData['id'];
        debugPrint("\n\nRazorpay Order Created: $orderId\n\n");
        openCheckout(orderId);
      } else {
        debugPrint("\n\nError creating Razorpay order: ${response.body}\n\n");
      }
    } catch (e) {
      debugPrint("\n\nException in createRazorpayOrder: $e\n\n");
    }
  }

  void openCheckout(String orderId) {
    String key = dotenv.env['razorpay_live_key_id'] ?? '';
    var options = {
      'key': key,
      'amount': amountInPaisa,
      'name': selectedName,
      'description': selectedDescription,
      'order_id': orderId,
    };

    try {
      _razorpay.open(options);
    } catch (e, stacktrace) {
      debugPrint('\n\nRazorpay Checkout Error: $e\n\n');
      debugPrint(stacktrace.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint("\n\nPayment Successful! ID: ${response.paymentId}\n\n");

    bookSubs(
      subscriptionId: subsId.isNotEmpty ? int.parse(subsId) : 0,
      paymentId: response.paymentId!,
      orderId: response.orderId!,
    );
    isTapped = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Text('Payment ID: ${response.paymentId}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeScreen())),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isTapped = false;
    debugPrint("\n\nPayment Failed: ${response.message}\n\n");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content:
            Text('Error: ${response.message}'), // Show actual error message
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> bookSubs({
    required int subscriptionId,
    required String paymentId,
    required String orderId,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    const String url =
        'https://divinesoulyoga.in/api/subscription-purchased-data';

    // Format the current date
    String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Convert all fields to strings
    final Map<String, dynamic> body = {
      'user_id': userId ?? '', // Ensure this is a string
      'subscription_id': subscriptionId.toString(), // Convert int to string
      'purchase_date': formattedDate, // Already a string
      'order_id': orderId, // Already a string
      'transaction_id': paymentId, // Already a string
      'status': "1", // Explicitly set as string
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      if (response.statusCode == 200) {
        debugPrint(response.body);
        debugPrint('\n\nSubscription booked successfully.\n\n');
      } else {
        debugPrint('\n\nFailed to book subscription: ${response.body}\n\n');
      }
    } catch (e) {
      debugPrint('\n\nError: $e');
    }
  }

  Future<void> fetchSubscriptions() async {
    try {
      final response = await http
          .get(Uri.parse('https://divinesoulyoga.in/api/subscription-Data'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          subscriptions = data['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load subscriptions');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching subscriptions: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<Userprovider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription',
            style: TextStyle(color: Color(0xffD45700))),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image.asset('assets/images/group1.png'),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: subscriptions.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final subscription = subscriptions[index];
                        final isSelected =
                            subscription['id'].toString() == subsId;
                        return Card(
                          color: isSelected
                              ? const Color(0xffD45700)
                              : Colors.white70,
                          child: ListTile(
                            title: Text(
                              "${subscription['name']} - ${subscription['validity']} ${subscription['validity'] == "1" ? 'month' : 'months'}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? Colors.white : Colors.black),
                            ),
                            subtitle: Text(
                              subscription['description'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            trailing: profileProvider.profileData!["user"]
                                        ["subscription_status"] ==
                                    "0"
                                ? Text(
                                    '₹${subscription['amount']}',
                                    style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black),
                                  )
                                : Text(
                                    "Already Subscribed\nValid till",
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                            selected: isSelected,
                            onTap: profileProvider.profileData!["user"]
                                        ["subscription_status"] ==
                                    "0"
                                ? () {
                                    setState(() {
                                      if (subsId ==
                                          subscription['id'].toString()) {
                                        subsId = "";
                                        subid = -1;
                                        amountInPaisa = 0;
                                        selectedName = "";
                                        selectedDescription = "";
                                      } else {
                                        subsId = subscription['id'].toString();
                                        subid = subscription['id'];
                                        amountInPaisa =
                                            int.parse(subscription['amount']) *
                                                100;
                                        selectedName = subscription['name'];
                                        selectedDescription =
                                            subscription['description'];
                                      }
                                    });
                                  }
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  profileProvider.profileData!["user"]["subscription_status"] ==
                          "0"
                      ? Center(
                          child: ElevatedButton(
                            onPressed: subsId.isEmpty
                                ? null
                                : () {
                                    if (!isTapped) {
                                      isTapped = true;
                                      debugPrint(
                                          "\n\nButton Pressed: Creating Razorpay Order...\n\n");
                                      debugPrint(
                                          "\n\nSubscription ID: $subsId\n\n");

                                      createRazorpayOrder().then((_) {
                                        isTapped = false;
                                      }).catchError((error) {
                                        debugPrint(
                                            "\n\nError in createRazorpayOrder(): $error\n\n");
                                        isTapped = false;
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: subsId.isEmpty
                                  ? Colors.grey
                                  : const Color(0xffD45700),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              textStyle: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            child: Text(
                              'Buy Subscription',
                              style: TextStyle(
                                color:
                                    subsId.isEmpty ? Colors.grey : Colors.white,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            ),
    );
  }
}
