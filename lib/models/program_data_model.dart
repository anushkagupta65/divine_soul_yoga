import 'dart:ffi';

class ProgramResponse {
  final String message;
  final List<Program> data;

  ProgramResponse({required this.message, required this.data});

  factory ProgramResponse.fromJson(Map<String, dynamic> json) {
    return ProgramResponse(
      message: json['message'] ?? '',
      data: (json['data'] as List).map((e) => Program.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class Program {
  final int id;
  final String title;
  final int programTypeId;
  final String image;
  final String isPaid;
  final String amount;
  final String createdAt;
  final String updatedAt;
  final bool paid;
  //final List<Course> courses;

  Program({
    required this.id,
    required this.title,
    required this.programTypeId,
    required this.image,
    required this.isPaid,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    required this.paid,
    //required this.courses,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      programTypeId: int.tryParse(json['program_type_id'].toString()) ?? 0,
      image: json['image'] ?? '',
      isPaid: json['is_paid'] ?? 'No',
      amount: json['amount'] ?? '0',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      paid: json['paid'] ?? false,
     // courses: (json['courses'] as List).map((e) => Course.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'program_type_id': programTypeId,
      'image': image,
      'is_paid': isPaid,
      'amount': amount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'paid' : paid,
      //'courses': courses.map((e) => e.toJson()).toList(),
    };
  }
}

// class Course {
//   final int id;
//   final int programId;
//   final String day;
//   final String audioPath;
//   final String audioName;
//   final String audioTime;
//   final String createdAt;
//   final String updatedAt;
//   final bool completed;
//
//   Course({
//     required this.id,
//     required this.programId,
//     required this.day,
//     required this.audioPath,
//     required this.audioName,
//     required this.audioTime,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.completed,
//   });
//
//   factory Course.fromJson(Map<String, dynamic> json) {
//     return Course(
//       id: int.tryParse(json['id'].toString()) ?? 0,
//       programId: int.tryParse(json['program_id'].toString()) ?? 0,
//       day: json['day'] ?? '',
//       audioPath: json['audio_path'] ?? '',
//       audioName: json['audio_name'] ?? '',
//       audioTime: json['audio_time'] ?? '',
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       completed: json['completed'] == true || json['completed'] == 'true', // Convert to bool
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
//       'completed': completed,
//     };
//   }
// }



class CourseResponse {
  final String message;
  final List<Course> data;

  CourseResponse({required this.message, required this.data});

  factory CourseResponse.fromJson(Map<String, dynamic> json) {
    return CourseResponse(
      message: json['message'] ?? '',
      data: (json['data'] as List).map((e) => Course.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class Course {
  final int id;
  final int programId;
  final String day;
  final String audioPath;
  final String audioName;
  final String audioTime;
  final String createdAt;
  final String updatedAt;
  final bool paid;
  final bool playable;

  Course({
    required this.id,
    required this.programId,
    required this.day,
    required this.audioPath,
    required this.audioName,
    required this.audioTime,
    required this.createdAt,
    required this.updatedAt,
    required this.paid,
    required this.playable,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: int.tryParse(json['id'].toString()) ?? 0,
      programId: int.tryParse(json['program_id'].toString()) ?? 0,
      day: json['day'] ?? '',
      audioPath: json['audio_path'] ?? '',
      audioName: json['audio_name'] ?? '',
      audioTime: json['audio_time'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      paid: json['paid'] == true || json['paid'] == 'true',
      playable: json['playable'] == true || json['playable'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'program_id': programId,
      'day': day,
      'audio_path': audioPath,
      'audio_name': audioName,
      'audio_time': audioTime,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'paid': paid,
      'playable': playable,
    };
  }
}
