import 'dart:convert';
import 'package:divine_soul_yoga/src/services/work_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:divine_soul_yoga/src/services/notifications.dart';
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
  List<dynamic> ifSubscribed = [];
  bool isLoading = true;
  late Razorpay _razorpay;
  int amountInPaisa = 0;
  String subsId = '';
  String selectedName = '';
  String selectedDescription = '';
  int subid = 0;
  bool isTapped = false;
  bool hasEverSubscribed = false;

  @override
  void initState() {
    super.initState();
    debugPrint('DEBUG: initState called');
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    initializeNotifications();
    _loadData();
  }

  Future<void> _loadData() async {
    final profileProvider = Provider.of<Userprovider>(context, listen: false);
    await profileProvider.fetchProfileData();
    await fetchSubscriptions();
    await subscribed();
    await _checkSubscriptionHistory();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? endDate = prefs.getString('subscription_end_date');
    if (endDate != null && ifSubscribed.isNotEmpty) {
      scheduleExpirationCheck();
    }
  }

  Future<void> _setTestSubscriptionDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime testDate = DateTime.now().add(const Duration(days: 3));
    await prefs.setString('subscription_end_date', testDate.toIso8601String());
    await scheduleExpirationCheck();
    debugPrint('DEBUG: Test subscription date set to $testDate');
  }

  Future<void> _checkSubscriptionHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool everSubscribed = prefs.getBool('hasEverSubscribed') ?? false;
    setState(() {
      hasEverSubscribed = everSubscribed || ifSubscribed.isNotEmpty;
    });
  }

  @override
  void dispose() {
    debugPrint('DEBUG: dispose called');
    _razorpay.clear();
    super.dispose();
  }

  Future<void> createRazorpayOrder() async {
    debugPrint('DEBUG: createRazorpayOrder called with subsId: $subsId');
    if (subsId.isEmpty) {
      debugPrint("Error: Subscription ID is empty. Cannot proceed.");
      return;
    }

    String keyId = dotenv.env['razorpay_live_key_id'] ?? '';
    String keySecret = dotenv.env['razorpay_live_key_secret'] ?? '';

    if (keyId.isEmpty || keySecret.isEmpty) {
      debugPrint("Error: Razorpay API keys are missing.");
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

      debugPrint("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String orderId = responseData['id'];
        debugPrint("Razorpay Order Created: $orderId");
        openCheckout(orderId);
      } else {
        debugPrint("Error creating Razorpay order: ${response.body}");
      }
    } catch (e) {
      debugPrint("Exception in createRazorpayOrder: $e");
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
      debugPrint('Razorpay Checkout Error: $e');
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('DEBUG: Payment Success - Payment ID: ${response.paymentId}');
    debugPrint('DEBUG: Order ID: ${response.orderId}');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userIdString = prefs.getString('user_id');
    int userId = int.tryParse(userIdString ?? '0') ?? 0;
    String purchaseDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    await bookSubs(
      userId: userId,
      subscriptionId: subsId.isNotEmpty ? int.parse(subsId) : 0,
      paymentId: response.paymentId!,
      orderId: response.orderId!,
      purchaseDate: purchaseDate,
    ).then((_) async {
      debugPrint('DEBUG: Refreshing data after success');
      final profileProvider = Provider.of<Userprovider>(context, listen: false);
      profileProvider.fetchProfileData();
      await subscribed();

      prefs.setBool('hasEverSubscribed', true);
      if (ifSubscribed.isNotEmpty) {
        String endDate = ifSubscribed[0]['end_date'];
        await prefs.setString('subscription_end_date', endDate);
        scheduleExpirationCheck();
      }

      setState(() {
        hasEverSubscribed = true;
      });
    });

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
    debugPrint("Payment Failed: ${response.message}");

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

  Future<void> bookSubs({
    required int userId,
    required int subscriptionId,
    required String paymentId,
    required String orderId,
    required String purchaseDate,
  }) async {
    debugPrint('DEBUG: bookSubs called with subscriptionId: $subscriptionId');
    debugPrint('DEBUG: userId: $userId');
    const String url =
        'https://divinesoulyoga.in/api/subscription-purchased-data';

    final Map<String, dynamic> body = {
      'user_id': userId,
      'subscription_id': subscriptionId,
      'transaction_id': paymentId,
      'order_id': orderId,
      'purchase_date': purchaseDate,
    };

    debugPrint('DEBUG: bookSubs request body: $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );
      debugPrint('DEBUG: bookSubs response status: ${response.statusCode}');
      debugPrint('DEBUG: bookSubs response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('DEBUG: Subscription booked successfully');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('subscriptionCheck', "1");
      } else {
        debugPrint('DEBUG: Failed to book subscription: ${response.body}');
      }
    } catch (e) {
      debugPrint('DEBUG: bookSubs error: $e');
    }
  }

  Future<void> fetchSubscriptions() async {
    debugPrint('DEBUG: fetchSubscriptions called');
    setState(() => isLoading = true);
    try {
      final response = await http
          .get(Uri.parse('https://divinesoulyoga.in/api/subscription-Data'));
      debugPrint('DEBUG: fetchSubscriptions status: ${response.statusCode}');
      debugPrint('DEBUG: fetchSubscriptions response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          subscriptions = data['data'] ?? [];
          isLoading = false;
        });
        debugPrint(
            'DEBUG: Available subscriptions count: ${subscriptions.length}');
      } else {
        throw Exception('Failed to load subscriptions');
      }
    } catch (error) {
      debugPrint('DEBUG: fetchSubscriptions error: $error');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching subscriptions: $error')),
      );
    }
  }

  Future<void> subscribed() async {
    debugPrint('DEBUG: subscribed called');
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    debugPrint('DEBUG: User ID for subscribed fetch: $userId');

    if (userId == null || userId.isEmpty) {
      debugPrint('DEBUG: No user ID found');
      setState(() {
        ifSubscribed = [];
        isLoading = false;
        isSubscribed = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          'https://divinesoulyoga.in/api/user-subscriptions?user_id=$userId'));
      debugPrint('DEBUG: subscribed status: ${response.statusCode}');
      debugPrint('DEBUG: subscribed response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ifSubscribed = data['data'] ?? [];
          isLoading = false;
          isSubscribed = ifSubscribed.isNotEmpty;
        });
        debugPrint('DEBUG: Subscribed plans count: ${ifSubscribed.length}');
      } else {
        throw Exception('Failed to load subscribed plans');
      }
    } catch (error) {
      debugPrint('DEBUG: subscribed error: $error');
      setState(() {
        ifSubscribed = [];
        isLoading = false;
        isSubscribed = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching subscribed plans: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<Userprovider>(context);
    debugPrint('DEBUG: Building UI');
    debugPrint('DEBUG: Profile data: ${profileProvider.profileData}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription',
            style: TextStyle(color: Color(0xffD45700))),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _setTestSubscriptionDate,
                          child: const Text('Set Test Subscription Date'),
                        ),
                      ),
                    ),
                    if (ifSubscribed.isNotEmpty) ...[
                      const Text(
                        'Your Active Subscriptions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffD45700),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        itemCount: ifSubscribed.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final subscription = ifSubscribed[index];
                          return Card(
                            elevation: 2,
                            color: const Color.fromARGB(255, 234, 246, 236),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        subscription['subscription_name'] ??
                                            'Unnamed Plan',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade600,
                                        ),
                                      ),
                                      Chip(
                                        label: const Text('Active'),
                                        backgroundColor: Colors.green.shade600,
                                        labelStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Valid till: ${subscription['end_date'] ?? 'N/A'}',
                                    style: TextStyle(
                                      color: Colors.green.shade600,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ] else
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'No Active Subscriptions',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      'Available Subscription Plans',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffD45700),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      itemCount: subscriptions.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final subscription = subscriptions[index];
                        final isSelected =
                            subscription['id'].toString() == subsId;
                        return Card(
                          elevation: 2,
                          color: isSelected
                              ? const Color(0xffD45700)
                              : Colors.white,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(
                              "${subscription['name']} - ${subscription['validity']} ${subscription['validity'] == "1" ? 'month' : 'months'}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              subscription['description'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            trailing: Text(
                              '₹${subscription['amount']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                if (subsId == subscription['id'].toString()) {
                                  subsId = "";
                                  subid = -1;
                                  amountInPaisa = 0;
                                  selectedName = "";
                                  selectedDescription = "";
                                } else {
                                  subsId = subscription['id'].toString();
                                  subid = subscription[
                                      'idOpacityChanges Requested by Client id'];
                                  amountInPaisa =
                                      int.parse(subscription['amount']) * 100;
                                  selectedName = subscription['name'];
                                  selectedDescription =
                                      subscription['description'];
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: subsId.isEmpty
                            ? null
                            : () {
                                debugPrint(
                                    'DEBUG: Button pressed with subsId: $subsId');
                                if (isSubscribed) {
                                  debugPrint('DEBUG: User already subscribed');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'You already have an active subscription'),
                                    ),
                                  );
                                  return;
                                }
                                if (!isTapped) {
                                  isTapped = true;
                                  debugPrint(
                                      "Button Pressed: Creating Razorpay Order...");
                                  createRazorpayOrder().then((_) {
                                    isTapped = false;
                                  }).catchError((error) {
                                    debugPrint(
                                        "Error in createRazorpayOrder(): $error");
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
                          hasEverSubscribed
                              ? 'Renew Subscription'
                              : 'Buy Subscription',
                          style: TextStyle(
                              color:
                                  subsId.isEmpty ? Colors.grey : Colors.white),
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
