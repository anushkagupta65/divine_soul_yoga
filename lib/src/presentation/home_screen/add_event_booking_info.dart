import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/eventmodel.dart';
import 'home_screen.dart';

class AddEventBookingInfo extends StatefulWidget {
  final EventModel eventData;
  const AddEventBookingInfo({super.key, required this.eventData});

  @override
  State<AddEventBookingInfo> createState() => _AddEventBookingInfoState();
}

class _AddEventBookingInfoState extends State<AddEventBookingInfo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _selectedGender;
  String? _selectedRelationship;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _relationships = [
    'Self',
    'Family',
  ];
  late Razorpay _razorpay;
  int amountInPaisa = 0;

  final List<Map<String, String>> _personList = [];
  bool isTapped = false;

  void showPaymentConfirmationDialog(
      BuildContext context, String eventName, String trainerName, int amount) {
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
                isTapped ? null : createRazorpayOrder();
                isTapped = true;
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

  Future<void> createRazorpayOrder() async {
    String keyId = "rzp_test_t9nKkE2yOuYEkA";
    String keySecret = "fLf4GyMehyvF4gY1IyaN0NxE";

    Map<String, dynamic> body = {
      "amount": amountInPaisa * 100,
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
            'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}' // Basic Auth header
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      debugPrint("Response Data: $responseData");
      // Extract the order_id from the response
      String orderId = responseData['id'];

      openCheckout(orderId);
    } else {
      debugPrint("Something went wrong while creating order");
    }
  }

  void openCheckout(String orderid) {
    var options = {
      'key': 'rzp_test_t9nKkE2yOuYEkA', // Replace with your Razorpay key
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
    createEventAttendee(
        orderId: response.orderId.toString(),
        paymentID: response.paymentId.toString());
    isTapped = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Text('Payment ID: ${response.paymentId}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
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

  Future<void> createEventAttendee({
    required String orderId,
    required String paymentID,
  }) async {
    debugPrint("Amount rs: $amountInPaisa");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    const String url = "https://divinesoulyoga.in/api/event-attendee";
    debugPrint('$_personList');

    // Prepare the request body
    final Map<String, dynamic> body = {
      "user_id": userId,
      "event_id": widget.eventData.id,
      "amount": amountInPaisa,
      "order_id": orderId,
      "payment_id": paymentID,
      "attendees": _personList,
    };

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(body),
      );

      // Handle the response
      if (response.statusCode == 200) {
        // Success
        debugPrint("Event attendee created successfully: ${response.body}");
      } else {
        // Error
        debugPrint("Failed to create event attendee: ${response.statusCode}");
        debugPrint("Response: ${response.body}");
      }
    } catch (e) {
      // Exception handling
      debugPrint("Error occurred: $e");
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final personDetails = {
        'name': _nameController.text.trim(),
        'age': _ageController.text.trim(),
        'gender': _selectedGender!,
        'relationship': _selectedRelationship!,
      };

      setState(() {
        _personList.add(personDetails);
      });

      // Reset the form after submission
      _formKey.currentState!.reset();
      setState(() {
        _selectedGender = null;
        _selectedRelationship = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Person successfully added!')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    // Setting up event handlers
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear(); // Clear all event handlers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Person to Event',
          style: TextStyle(color: Color(0xffD45700)),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Person Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffD45700),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter age';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.wc),
                      ),
                      items: _genders.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a gender';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedRelationship,
                      decoration: const InputDecoration(
                        labelText: 'Relationship',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group),
                      ),
                      items: _relationships.map((relationship) {
                        return DropdownMenuItem(
                          value: relationship,
                          child: Text(relationship),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRelationship = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a relationship';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _submitForm();
                          _nameController.clear();
                          _ageController.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffD45700),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text(
                          'Add Person',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Added Persons',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffD45700),
                ),
              ),
              const SizedBox(height: 16),
              _personList.isEmpty
                  ? const Center(
                      child: Text(
                        'No persons added yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _personList.length,
                      itemBuilder: (context, index) {
                        final person = _personList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xffD45700),
                              child: Text(
                                person['name']![0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(person['name']!),
                            subtitle: Text(
                              'Age: ${person['age']}\nGender: ${person['gender']}\nRelationship: ${person['relationship']}',
                              style: const TextStyle(height: 1.5),
                            ),
                          ),
                        );
                      },
                    ),
              _personList.isNotEmpty
                  ? Center(
                      child: ElevatedButton(
                        onPressed: () {
                          showPaymentConfirmationDialog(
                              context,
                              widget.eventData.title,
                              widget.eventData.trainer,
                              int.parse(widget.eventData.amount) *
                                  _personList.length);
                          setState(() {
                            amountInPaisa = int.parse(widget.eventData.amount) *
                                _personList.length;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffD45700),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text(
                          'Book Event',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
