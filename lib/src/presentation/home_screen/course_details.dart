import 'dart:convert';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/program_data_model.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String days;
  final String courseId;

  const CourseDetailsScreen({
    super.key,
    required this.days,
    required this.courseId,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  late AudioPlayer _audioPlayer;
  Course? course;
  int? _currentlyPlayingIndex; // Index of the currently playing audio
  Duration _currentPosition = Duration.zero;
  Duration _trackDuration = Duration.zero;
  int programId = 0; // To control audio sequence
  bool isTapped = false;
  late Future<CourseResponse> futureCourses;
  Set<int> completedAudios = {};

  Future<CourseResponse> fetchCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';
    debugPrint(userId);
    debugPrint("course ID ${widget.courseId}");
    debugPrint("course days ${widget.days}");
    final String url =
        'https://divinesoulyoga.in/api/audio/${widget.courseId}/${widget.days}/${userId}';
    debugPrint(url);
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
    // Define the API endpoint
    const String url = "https://divinesoulyoga.in/api/complete-course";
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString('user_id');
    if (userId == null) {
      debugPrint("Error: user_id is null");
      return;
    }

    // Create the request body
    final Map<String, dynamic> requestBody = {
      "user_id": userId,
      "course_id": courseId,
      "program_id": programId
    };
    debugPrint("Request body = ${requestBody.toString()}");

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(requestBody),
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("API Response Status Code: ${response.statusCode}");
      debugPrint("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("Course completed successfully: ${response.body}");
        //CourseOverviewScreen.fetchCourses(widget.type);

        setState(() {
          futureCourses = fetchCourses();
        });
        //Navigator.push(context, MaterialPageRoute( builder: (context) => C));
      } else {
        debugPrint("Failed to complete course: ${response.statusCode}");
        debugPrint("Error response: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error occurred: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioSession();
    futureCourses = fetchCourses();

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
        completedAudios.add(programId); // Mark track as completed
        completeCourse(programId, int.parse(widget.courseId));
        setState(() {
          _currentlyPlayingIndex = null;
        });
      }
    });
  }

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

  void _handleTileTap(int index, Course course, List<Course> courses) {
    if (!course.playable) {
      _showDialog("Please finish the previous audio before accessing this.");
    } else {
      programId = course.id;
      _playTrack(index, course.audioPath);
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Access Denied"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final coursesList = course;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                  return const Center(
                    child: Text("No courses available"),
                  );
                }

                List<Course> courses = snapshot.data!.data;
                return ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    final isPlaying =
                        _currentlyPlayingIndex == index && _audioPlayer.playing;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Card(
                        child: ListTile(
                            onTap: () => _handleTileTap(index, course, courses),
                            leading: Text(
                              course.audioTime,
                              style: const TextStyle(fontSize: 16),
                            ),
                            title: Text(course.audioName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            trailing: course.playable == true
                                ? IconButton(
                                    icon: Icon(
                                      isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: const Color(0xffD45700),
                                    ),
                                    onPressed: () {
                                      programId = course.id;
                                      _playTrack(index, course.audioPath);
                                    },
                                  )
                                : const SizedBox()),
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
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        _trackDuration.toString().split('.').first,
                        style: const TextStyle(color: Colors.black),
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
                        _audioPlayer.seek(
                          Duration(seconds: value.toInt()),
                        );
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
