import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/userprovider.dart';
import 'home_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
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
        'Authorization': 'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}'
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      String orderId = responseData['id'];
      openCheckout(orderId);
    } else {
      print("Error creating Razorpay order: ${response.body}");
    }
  }

  void openCheckout(String orderId) {
    var options = {
      'key': 'rzp_test_t9nKkE2yOuYEkA',
      'amount': amountInPaisa,
      'name': selectedName,
      'description': selectedDescription,
      'order_id': orderId,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
     bookSubs(
      subscriptionId: int.parse(subsId),
      paymentId: response.paymentId!,
      orderId: response.orderId!,
    );
     isTapped = false;



     // if (response.paymentId != null && response.orderId != null) {
    //    bookSubs(
    //     subscriptionId: int.parse(subsId),
    //     paymentId: response.paymentId!,
    //     orderId: response.orderId!,
    //   );
    // } else {
    //   print("Payment ID or Order ID is null.");
    // }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Successful'),
        content: Text('Payment ID: ${response.paymentId}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen())),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isTapped = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Failed'),
        content: Text('Error: ${response.message}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
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
    const String url = 'https://divinesoulyoga.in/api/subscription-purchased-data';

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
        print(response.body);
        print('Subscription booked successfully.');
      } else {
        print('Failed to book subscription: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  Future<void> fetchSubscriptions() async {
    try {
      final response =
      await http.get(Uri.parse('https://divinesoulyoga.in/api/subscription-Data'));
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
        title: Text('Subscription', style: TextStyle(color: Color(0xffD45700))),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/group1.png'),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: subscriptions.length,
                physics: NeverScrollableScrollPhysics(), // Prevent internal scrolling
                shrinkWrap: true, // Allow ListView to take only required space
                itemBuilder: (context, index) {
                  final subscription = subscriptions[index];
                  final isSelected = subscription['id'].toString() == subsId;
                  return Card(
                    color: isSelected ? Color(0xffD45700) : Colors.white70,
                    child: ListTile(
                      title: Text(
                        "${subscription['name']} - ${subscription['validity']} months",
                        style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black),
                      ),
                      subtitle: Text(subscription['description'], style: TextStyle(color: isSelected ? Colors.white :Colors.black),),
                      trailing: profileProvider.profileData!["user"]["subscription_status"] == "0"
                      ?Text('₹${subscription['amount']}') : Text("Subscribed", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),

                      selected: isSelected,
                      onTap: () {
                        setState(() {
                          subsId = subscription['id'].toString();
                          subid = subscription['id'];
                          amountInPaisa = int.parse(subscription['amount']) * 100;
                          selectedName = subscription['name'];
                          selectedDescription = subscription['description'];
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 50,),

            profileProvider.profileData!["user"]["subscription_status"] == "0"
            ?
            Center(
              child: ElevatedButton(
                onPressed: subsId.isEmpty
                    ? null
                    : () {
                  isTapped ? null :createRazorpayOrder();
                   isTapped = true;

                },
                child: Text(
                  'Buy Subscription',
                  style: TextStyle(
                    color: subsId.isEmpty ? Colors.grey : Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  subsId.isEmpty ? Colors.grey : Color(0xffD45700),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            )
                : SizedBox()
            //Center(child: Text("Already Subscribed", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),))
          ],
        ),
      ),
    );
  }

}
