import 'dart:async';
import 'dart:convert';
import 'package:divine_soul_yoga/src/presentation/home_screen/add_event_booking_info.dart';
import 'package:divine_soul_yoga/src/models/eventmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../api_service/apiservice.dart';

class EventDetails extends StatefulWidget {
  final EventModel eventData;
  const EventDetails({super.key, required this.eventData});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  late Timer _timer;
  late Duration _remainingTime;
  late Razorpay _razorpay;
  int amountInPaisa = 0;

  @override
  void initState() {
    super.initState();
    amountInPaisa = (int.parse(widget.eventData.amount) * 100);
    // Initialize the remaining time by calculating the difference from now
    _remainingTime = DateTime.parse(widget.eventData.startDatetime)
        .difference(DateTime.now());

    // Update the remaining time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = DateTime.parse(widget.eventData.startDatetime)
            .difference(DateTime.now());
      });
    });

    _razorpay = Razorpay();

    // Setting up event handlers
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();

    _razorpay.clear(); // Clear all event handlers
    super.dispose();
  }

  Future<void> createRazorpayOrder() async {
    String keyId = dotenv.env['razorpay_key_id']!;
    String keySecret = dotenv.env['razorpay_key_secret']!;

    Map<String, dynamic> body = {
      "amount": amountInPaisa,
      "currency": "INR",
      "receipt": "receipt#1",
      "payment_capture": 1
    };

    var response = await http.post(
      Uri.https("api.razorpay.com", "/v1/orders"), // Using https
      body: jsonEncode(body), // Convert body to JSON
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${keyId}:$keySecret'))}' // Basic Auth header
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print("Response Data: $responseData");
      // Extract the order_id from the response
      String orderId = responseData['id'];

      openCheckout(orderId);
    } else {
      print("Something went wrong while creating order");
    }
  }

  void openCheckout(String orderid) {
    String key = dotenv.env['razorpay_key_id']!;
    var options = {
      'key': key,
      'amount': amountInPaisa * 100,
      'name': widget.eventData.title,
      'description': widget.eventData.title,
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
    // Do something when payment succeeds
    ApiService().bookEvent(
      eventId: widget.eventData.id.toString(),
      amount: widget.eventData.amount,
      orderId: response.orderId.toString(),
      paymentId: response.paymentId.toString(),
    );

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
    // Do something when payment fails
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

  String formatDate(String datetime) {
    final parsedDate = DateTime.parse(datetime); // Parse string to DateTime
    return DateFormat('MMM dd yyyy')
        .format(parsedDate); // Format to "Jan 11 2024"
  }

  String formatTime(String datetime) {
    final parsedDate = DateTime.parse(datetime); // Parse string to DateTime
    return DateFormat('hh:mm a')
        .format(parsedDate); // Format to time (e.g., 01:02 AM)
  }

  void bookingforfree() {
    Navigator.pop(context);
    var uuid = const Uuid().v4();

    ApiService().bookEvent(
        eventId: widget.eventData.id.toString(),
        amount: widget.eventData.amount,
        orderId: uuid,
        paymentId: uuid);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: const Text('Event Booked'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showPaymentConfirmationDialog(BuildContext context, String eventName,
      String trainerName, String amount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: const Text(
            'Payment Confirmation',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Event Name:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Text(
                eventName,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Trainer Name:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Text(
                trainerName,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Amount:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rs. $amount',
                style: const TextStyle(fontSize: 16.0, color: Colors.green),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Proceed with the payment action
                widget.eventData.amount != "0"
                    ? createRazorpayOrder() //Navigator.of(context).pop(); // Close dialog
                    : bookingforfree();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffD45700),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('Confirm Payment'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // String countdown = _formatDuration(_remainingTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Event Details",
          style: TextStyle(
            color: Color(0xffD45700),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: const Color(0xffD45700),
              height: MediaQuery.of(context).size.height * 0.25,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.eventData.title,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${formatDate(widget.eventData.startDatetime)} to ${formatDate(widget.eventData.endDatetime)}",
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${formatTime(widget.eventData.startDatetime)} to ${formatTime(widget.eventData.endDatetime)}",
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  buildCountdown(_remainingTime),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                      'https://divinesoulyoga.in/${widget.eventData.image}')),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Html(
                data: widget.eventData.description,
                style: {
                  "body": Style(
                    textAlign: TextAlign.justify, // Justify text
                  ),
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Html(data: 'Trainer: ${widget.eventData.trainer}'),
                  Html(data: 'Joining Fee: ${widget.eventData.amount}'),
                  Html(data: 'Venue: ${widget.eventData.location}'),
                  Html(
                      data:
                          'Contact Number: ${widget.eventData.contactNumber}'),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffD45700),
                    foregroundColor: const Color(0xffFFFFFF),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    widget.eventData.paid != true
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddEventBookingInfo(
                                      eventData: widget.eventData,
                                    )),
                          )
                        : null;
                  },
                  child: Text(
                    widget.eventData.paid != true ? 'Book Event' : "Booked",
                    style: const TextStyle(fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return "Event Expired";
    }
    String days = duration.inDays > 0 ? "${duration.inDays}d " : "";
    String hours =
        (duration.inHours % 24) > 0 ? "${(duration.inHours % 24)}h " : "";
    String minutes =
        (duration.inMinutes % 60) > 0 ? "${(duration.inMinutes % 60)}m " : "";
    String seconds =
        (duration.inSeconds % 60) > 0 ? "${(duration.inSeconds % 60)}s" : "";
    return "$days$hours$minutes$seconds";
  }

  Widget buildCountdown(Duration duration) {
    if (duration.isNegative) {
      return const Text(
        "Event Expired",
        style: TextStyle(fontSize: 18, color: Colors.white),
      );
    }

    int days = duration.inDays;
    int hours = duration.inHours % 24;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;

    List<Map<String, String>> countdownData = [
      {"label": "Days", "value": days.toString()},
      {"label": "Hours", "value": hours.toString()},
      {"label": "Minutes", "value": minutes.toString()},
      {"label": "Seconds", "value": seconds.toString()},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: countdownData.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  item['value']!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffD45700),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['label']!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
