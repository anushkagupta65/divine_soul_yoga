import 'package:divine_soul_yoga/src/api_service/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/userprovider.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<Userprovider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contact Us',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w400,
              color: Color(0xffD45700)),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Contact Information Section
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 20),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.900,
                      child: Image.asset(
                        'assets/images/frame1.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 40.0, right: 30),
                            child: Text(
                              "Contact Information",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xffFFFFFF)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 15.0,
                              right: 20,
                            ),
                            child: Image.asset('assets/images/ct1.png'),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 15.0, right: 20),
                            child: Text(
                              "+91-91154 92700",
                              style: TextStyle(color: Color(0xffFFFFFF)),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 15.0, right: 20),
                            child: Image.asset('assets/images/ct2.png'),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 15.0, right: 20),
                            child: Text(
                              'info@divinesoulyoga.com',
                              style: TextStyle(color: Color(0xffFFFFFF)),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 15.0, right: 20),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image.asset('assets/images/sc1.png'),
                                  Image.asset('assets/images/sc2.png'),
                                  Image.asset('assets/images/sc3.png'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Inquiry Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Send us an inquiry',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Interested in joining our classes but feeling intimidated? Don’t be. Send us a note!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),

              // Name Field
              Container(
                margin: EdgeInsets.all(20),
                child: TextFormField(
                  controller: _nameController,
                  style: TextStyle(fontSize: 16, color: Color(0xffD45700)),
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffD45700)),
                    ),
                    hintText: "Enter your name",
                    labelText: "Your name",
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffD45700),
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff000000)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
              ),

              // Email Field
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _emailController,
                  style: TextStyle(fontSize: 16, color: Color(0xffD45700)),
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffD45700)),
                    ),
                    hintText: "Enter your email",
                    labelText: "Email",
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffD45700),
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff000000)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    } else if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
              ),

              // Phone Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _phoneController,
                  style: TextStyle(fontSize: 16, color: Color(0xffD45700)),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffD45700)),
                    ),
                    hintText: "Enter your phone number",
                    labelText: "Phone Number",
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD45700),
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff000000)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
              ),

              // Message Field
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: _messageController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Write your message...",
                    hintStyle: TextStyle(color: Color(0xff8D8D8D)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xffD45700)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Message is required';
                    }
                    return null;
                  },
                ),
              ),

              // Submit Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.900,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await ApiService().contactUs(
                          name: _nameController.text,
                          email: _emailController.text,
                          message: _messageController.text,
                          mobile: _phoneController.text,
                          userId: profileProvider.profileData!['user']['id']
                              .toString(),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Message sent successfully!')),
                        );

                        _nameController.clear();
                        _emailController.clear();
                        _phoneController.clear();
                        _messageController.clear();
                      }
                    },
                    child: Text(
                      'Send Message',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffD45700),
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
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
