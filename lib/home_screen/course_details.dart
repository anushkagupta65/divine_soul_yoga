import 'dart:convert';

import 'package:audio_session/audio_session.dart';
import 'package:divine_soul_yoga/home_screen/course_overview.dart';
import 'package:divine_soul_yoga/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../api_service/apiservice.dart';
import '../models/program_data_model.dart';

class CourseDetailsScreen extends StatefulWidget {
  // final Program course;
   final String days;
   final String courseId;

  const CourseDetailsScreen({
    Key? key, required this.days, required this.courseId,
  }) : super(key: key);

  @override
  _CourseDetailsScreenState createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  late AudioPlayer _audioPlayer;
   Course? course;
  int? _currentlyPlayingIndex; // Index of the currently playing audio
  Duration _currentPosition = Duration.zero;
  Duration _trackDuration = Duration.zero;
  int programId = 0;
  // late Razorpay _razorpay;
  // int amountInPaisa = 0;
  int _lastPlayableIndex = 0; // To control audio sequence
  bool isTapped = false;
  late Future<CourseResponse> futureCourses;

  Future<CourseResponse> fetchCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';
    print(userId);
    print("course ID ${widget.courseId}");
    print("course days ${widget.days}");
    final String url =
        'https://divinesoulyoga.in/api/audio/${widget.courseId}/${widget.days}/${userId}';
    print(url);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          print(jsonDecode(response.body));
          return CourseResponse.fromJson(jsonDecode(response.body));
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> completeCourse(int courseId, int programId) async {
    //print(widget.type);
    // Define the API endpoint
    const String url = "https://divinesoulyoga.in/api/complete-course";
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString('user_id');
    if (userId == null) {
      print("Error: user_id is null");
      return;
    }

    // Create the request body
    final Map<String, dynamic> requestBody = {
      "user_id": userId,
      "course_id": courseId,
      "program_id": programId
    };
    print(requestBody);

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(requestBody),
        headers: {"Content-Type": "application/json"},
      );

      print("API Response Status Code: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("Course completed successfully: ${response.body}");
        //CourseOverviewScreen.fetchCourses(widget.type);

        setState(() {
          futureCourses = fetchCourses();        });
        //Navigator.push(context, MaterialPageRoute( builder: (context) => C));
      } else {
        print("Failed to complete course: ${response.statusCode}");
        print("Error response: ${response.body}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }

  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioSession();
    futureCourses = fetchCourses();

    //amountInPaisa = (int.parse(course.amount) * 100);

    // _razorpay = Razorpay();
    //
    // // Setting up event handlers
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    // Listen to player position updates
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _trackDuration = duration ?? Duration.zero;
      });
    });

    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        completeCourse(programId, int.parse(widget.courseId));
        setState(() {
          _currentlyPlayingIndex = null; // Reset current track index
        });
      }
    });
  }

  // Future<void> createRazorpayOrder() async {
  //   String keyId = "rzp_test_t9nKkE2yOuYEkA";
  //   String keySecret = "fLf4GyMehyvF4gY1IyaN0NxE";
  //
  //   Map<String, dynamic> body = {
  //     "amount": amountInPaisa,
  //     "currency": "INR",
  //     "receipt": "receipt#1",
  //     "payment_capture": 1
  //   };
  //
  //   var response = await http.post(
  //     Uri.https("api.razorpay.com", "/v1/orders"),
  //     body: jsonEncode(body),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}'
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final responseData = jsonDecode(response.body);
  //     print("Response Data: $responseData");
  //     String orderId = responseData['id'];
  //     openCheckout(orderId);
  //   } else {
  //     print("Something went wrong while creating order");
  //   }
  // }
  //
  // void openCheckout(String orderid) {
  //   var options = {
  //     'key': 'rzp_test_t9nKkE2yOuYEkA',
  //     'amount': amountInPaisa * 100,
  //     'name': widget.course.title,
  //     'description': widget.course.title,
  //     'order_id': orderid,
  //   };
  //
  //   try {
  //     _razorpay.open(options);
  //   } catch (e) {
  //     debugPrint('Error: $e');
  //   }
  // }
  //
  // void _handlePaymentSuccess(PaymentSuccessResponse response) {
  //   Navigator.pop(context);
  //   ApiService().buyCourse(
  //     courseId: widget.course.id.toString(),
  //     amount: widget.course.amount,
  //     orderId: response.orderId.toString(),
  //     paymentId: response.paymentId.toString(),
  //     paymentStatus: "true",
  //   );
  //   isTapped = false;
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Payment Successful'),
  //       content: Text('Payment ID: ${response.paymentId}'),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             // Navigator.push(
  //             //   context,
  //             //   MaterialPageRoute(
  //             //     builder: (context) => HomeScreen(),
  //             //   ),
  //             // );
  //           },
  //           child: Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // void _handlePaymentError(PaymentFailureResponse response) {
  //   ApiService().buyCourse(
  //     courseId: widget.course.id.toString(),
  //     amount: widget.course.amount,
  //     orderId: response.error.toString(),
  //     paymentId: response.toString(),
  //     paymentStatus: "false",
  //   );
  //   isTapped = false;
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Payment Failed'),
  //       content: Text('Error: ${response.message}'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void _playTrack(int index, String url) async {
    if (_currentlyPlayingIndex == index) {
      if (_audioPlayer.playing) {
        _audioPlayer.pause();
      } else {
        _audioPlayer.play();
      }
    } else {
      await _audioPlayer.stop();
      try {
        await _audioPlayer.setUrl("https://divinesoulyoga.in/$url");
        _audioPlayer.play();
        setState(() {
          _currentlyPlayingIndex = index;
        });
      } catch (e) {
        debugPrint('Error playing audio: $e');
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesList = course;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Audio",
          style: TextStyle(color: Color(0xffD45700)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<CourseResponse>(
              future: futureCourses,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                  return Center(child: Text("No courses available"));
                }

                List<Course> courses = snapshot.data!.data;
                return ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    final isPlaying =
                        _currentlyPlayingIndex == index && _audioPlayer.playing;

                    return Card(
                      child: ListTile(
                        leading: Text(course.audioTime),
                        title: Text(course.audioName,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        //subtitle: Text(course.audioName),
                        trailing:
                            course.playable == true
                         ? IconButton(
                          icon:
                              Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Color(0xffD45700),),
                          onPressed: () {
                            programId = course.id;
                            _playTrack(index, course.audioPath);
                            } ,
                        ) : SizedBox()
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_currentlyPlayingIndex != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Display current time and track duration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _currentPosition.toString().split('.').first,
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        _trackDuration.toString().split('.').first,
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  // Seek bar
                  Slider(
                    min: 0.0,
                    max: _trackDuration.inSeconds.toDouble(),
                    value: _currentPosition.inSeconds.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
