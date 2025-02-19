class TestimonialsResponse {
  final String message;
  final List<TestimonialsData> data;

  TestimonialsResponse({
    required this.message,
    required this.data,
  });

  factory TestimonialsResponse.fromJson(Map<String, dynamic> json) {
    return TestimonialsResponse(
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>).map((e) => TestimonialsData.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class TestimonialsData {
  final int? id;  // Changed from int to int?
  final int? userId;  // Changed from int to int?
  final String name;
  final String detail;
  final String date;
  final String? status;
  final String createdAt;
  final String updatedAt;

  TestimonialsData({
    this.id,
    this.userId,
    required this.name,
    required this.detail,
    required this.date,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TestimonialsData.fromJson(Map<String, dynamic> json) {
    return TestimonialsData(
      id: json['id'],  // This can now accept null
      userId: json['user_id'],  // This can now accept null
      name: json['name'] ?? '',
      detail: json['detail'] ?? '',
      date: json['date'] ?? '',
      status: json['status'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'detail': detail,
      'date': date,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
