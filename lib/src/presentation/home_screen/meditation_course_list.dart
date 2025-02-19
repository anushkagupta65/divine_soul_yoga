// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:audio_session/audio_session.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class MeditationCourseList extends StatefulWidget {
//    final id;
//   const MeditationCourseList({super.key, this.id});
//
//   @override
//   State<MeditationCourseList> createState() => _MeditationCourseListState();
// }
//
// class _MeditationCourseListState extends State<MeditationCourseList> {
//   late AudioPlayer _audioPlayer; // Single audio player for all tracks
//   String? _currentTrackTitle; // Currently playing track title
//   Duration _currentPosition = Duration.zero;
//   Duration _trackDuration = Duration.zero;
//
//   late Future<List<Course>> _coursesFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _audioPlayer = AudioPlayer();
//     _initAudioSession();
//
//     // Listen to player position updates
//     _audioPlayer.positionStream.listen((position) {
//       setState(() {
//         _currentPosition = position;
//       });
//     });
//
//     // Listen to duration changes
//     _audioPlayer.durationStream.listen((duration) {
//       setState(() {
//         _trackDuration = duration ?? Duration.zero;
//       });
//     });
//
//     // Fetch courses
//     _coursesFuture = fetchCourses();
//   }
//
//   Future<void> _initAudioSession() async {
//     final session = await AudioSession.instance;
//     await session.configure(const AudioSessionConfiguration.music());
//   }
//
//   Future<List<Course>> fetchCourses() async {
//     const url = 'https://divinesoulyoga.in/api/programData';
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         print(jsonDecode(response.body));
//         final responseData = json.decode(response.body)['data']['courses'] as List;
//         print(responseData);
//         // Filter courses based on widget.id and program_type_id
//         return responseData
//             .map((data) => Course.fromJson(data))
//             .where((course) => course.programTypeId == widget.id)
//             .toList();
//       } else {
//         throw Exception('Failed to load courses');
//       }
//     } catch (error) {
//       throw Exception('Failed to load courses: $error');
//     }
//   }
//
//
//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }
//
//   void _playTrack(String title, String url) async {
//     try {
//       await _audioPlayer.setUrl(url);
//       setState(() {
//         _currentTrackTitle = title;
//       });
//       _audioPlayer.play();
//     } catch (e) {
//       debugPrint('Error playing audio: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Meditation Course List",
//           style: TextStyle(
//             color: Color(0xffD45700),
//           ),
//         ),
//       ),
//       body: FutureBuilder<List<Course>>(
//         future: _coursesFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text('Error: ${snapshot.error}'),
//             );
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No courses available.'));
//           } else {
//             final courses = snapshot.data!;
//             return Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: courses.length,
//                     itemBuilder: (context, index) {
//                       final course = courses[index];
//                       return Card(
//                         margin: const EdgeInsets.all(8.0),
//                         child: Column(
//                           children: [
//                              Image.network(
//                                 //width: 100,
//                                 "https://divinesoulyoga.in/${course.image}", fit: BoxFit.cover),
//                             ListTile(
//
//                               title: Text(course.title),
//                               subtitle: Text('Duration: ${course.audioTime}'),
//                               trailing: course.isPaid == 1 ?
//                               IconButton(
//                                 icon: Icon(
//                                   _currentTrackTitle == course.title && _audioPlayer.playing
//                                       ? Icons.pause
//                                       : Icons.play_arrow,
//                                 ),
//                                 onPressed: () {
//                                   if (_currentTrackTitle == course.title && _audioPlayer.playing) {
//                                     _audioPlayer.pause();
//                                   } else {
//                                     _playTrack(course.title, "https://divinesoulyoga.in/${course.audioPath}");
//                                   }
//                                 },
//                               )
//                                   : Container(
//                                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Color(0xffD45700),),
//                                 height: 40,
//                                 width: 60,
//                                 child: Center(child: Text('Buy')),
//                               )
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 if (_currentTrackTitle != null)
//                   Container(
//                     color: Colors.grey[900],
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           _currentTrackTitle!,
//                           style: const TextStyle(color: Colors.white, fontSize: 16),
//                         ),
//                         Row(
//                           children: [
//                             Text(
//                               _formatDuration(_currentPosition),
//                               style: const TextStyle(color: Colors.white),
//                             ),
//                             Expanded(
//                               child: Slider(
//                                 value: _currentPosition.inSeconds.toDouble(),
//                                 max: _trackDuration.inSeconds.toDouble(),
//                                 min: 0.0,
//                                 onChanged: (value) {
//                                   _audioPlayer.seek(Duration(seconds: value.toInt()));
//                                 },
//                                 activeColor: Colors.blue,
//                                 inactiveColor: Colors.grey,
//                               ),
//                             ),
//                             Text(
//                               _formatDuration(_trackDuration),
//                               style: const TextStyle(color: Colors.white),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             IconButton(
//                               icon: Icon(
//                                 _audioPlayer.playing ? Icons.pause : Icons.play_arrow,
//                                 color: Colors.white,
//                               ),
//                               onPressed: () {
//                                 if (_audioPlayer.playing) {
//                                   _audioPlayer.pause();
//                                 } else {
//                                   _audioPlayer.play();
//                                 }
//                               },
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   String _formatDuration(Duration duration) {
//     final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return '$minutes:$seconds';
//   }
// }
//
// class ProgramData {
//   final String message;
//   final List<Program> data;
//
//   ProgramData({required this.message, required this.data});
//
//   factory ProgramData.fromJson(Map<String, dynamic> json) {
//     return ProgramData(
//       message: json['message'],
//       data: List<Program>.from(json['data'].map((program) => Program.fromJson(program))),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'message': message,
//       'data': data.map((program) => program.toJson()).toList(),
//     };
//   }
// }
//
// class Program {
//   final int id;
//   final String title;
//   final int programTypeId;
//   final String image;
//   final String isPaid;
//   final String amount;
//   final String createdAt;
//   final String updatedAt;
//   final List<Course> courses;
//
//   Program({
//     required this.id,
//     required this.title,
//     required this.programTypeId,
//     required this.image,
//     required this.isPaid,
//     required this.amount,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.courses,
//   });
//
//   factory Program.fromJson(Map<String, dynamic> json) {
//     return Program(
//       id: json['id'],
//       title: json['title'],
//       programTypeId: json['program_type_id'],
//       image: json['image'],
//       isPaid: json['is_paid'],
//       amount: json['amount'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//       courses: List<Course>.from(json['courses'].map((course) => Course.fromJson(course))),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'program_type_id': programTypeId,
//       'image': image,
//       'is_paid': isPaid,
//       'amount': amount,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//       'courses': courses.map((course) => course.toJson()).toList(),
//     };
//   }
// }
//
// class Course {
//   final int id;
//   final int programId;
//   final String day;
//   final String audioPath;
//   final String audioTime;
//   final String createdAt;
//   final String updatedAt;
//
//   Course({
//     required this.id,
//     required this.programId,
//     required this.day,
//     required this.audioPath,
//     required this.audioTime,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory Course.fromJson(Map<String, dynamic> json) {
//     return Course(
//       id: json['id'],
//       programId: json['program_id'],
//       day: json['day'],
//       audioPath: json['audio_path'],
//       audioTime: json['audio_time'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'program_id': programId,
//       'day': day,
//       'audio_path': audioPath,
//       'audio_time': audioTime,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//     };
//   }
// }
