import 'dart:io';
import 'package:divine_soul_yoga/src/models/blogmodel.dart';
import 'package:divine_soul_yoga/src/models/eventmodel.dart';
import 'package:divine_soul_yoga/src/models/studio_model.dart';
import 'package:divine_soul_yoga/src/models/testimonialsmodel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/atttendedevent.dart';
import '../models/gallerymmodel.dart';
import '../models/program_data_model.dart';

class ApiService {
  Future<void> buyCourse({
    required String courseId,
    required String amount,
    required String orderId,
    required String paymentId,
    required String paymentStatus,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString('user_id');

    String url =
        'https://divinesoulyoga.in/api/courses-payment-update?user_id=$userId&course_id=$courseId&payment_status=$paymentStatus&amount=$amount&payment_id=$paymentId';

    print(userId.toString());
    print(courseId.toString());
    print(amount.toString());
    print(orderId.toString());
    print(paymentId.toString());

    // Create the request body

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
      );

      // Handle the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        eventData(userId!);
        print('Booking Successful: $data');
      } else {
        print('Failed to Buy Course. Status Code: ${response.statusCode}');
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future<void> bookEvent({
    required String eventId,
    required String amount,
    required String orderId,
    required String paymentId,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString('user_id');

    const String url = 'https://divinesoulyoga.in/api/book_eventsData';

    print(userId.toString());
    print(eventId);
    print(amount);
    print(orderId);
    print(paymentId);

    // Create the request body
    final Map<String, String> body = {
      'user_id': userId.toString(),
      'event_id': eventId,
      'amount': amount,
      'order_id': orderId,
      'payment_id': paymentId,
    };

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      // Handle the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        eventData(userId!);
        print('Booking Successful: $data');
      } else {
        print('Failed to book event. Status Code: ${response.statusCode}');
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future<void> contactUs({
    required String name,
    required String email,
    required String message,
    required String mobile,
    required String userId,
  }) async {
    // _isLoading = true;
    // notifyListeners();

    final Uri url =
        Uri.parse('https://divinesoulyoga.in/api/updateContactlist');

    try {
      final response = await http.post(
        url,
        body: {
          'name': name,
          'email': email,
          'massage': message,
          'mobile': mobile,
          'user_id': userId,
        },
      );

      if (response.statusCode == 200) {
        // Handle success (e.g., show success message or navigate)
        // Parse the response if necessary
        var data = jsonDecode(response.body);
        print('Feedback submitted successfully!');
        print(data);
      } else {
        print('Failed to submit contact us form. Server error.');
      }
    } catch (e) {
      print('Failed to submit contact us. Network error: $e');
    }
  }

  Future<void> submitFeedback({
    required String name,
    required String description,
    required String date,
    required String status,
    required String userId,
  }) async {
    // _isLoading = true;
    // notifyListeners();

    final Uri url =
        Uri.parse('https://divinesoulyoga.in/api/updatetestimonialssave');

    try {
      final response = await http.post(
        url,
        body: {
          'name': name,
          'description': description,
          'date': date,
          'status': status,
          'user_id': userId,
        },
      );

      if (response.statusCode == 200) {
        // Handle success (e.g., show success message or navigate)
        // Parse the response if necessary
        var data = jsonDecode(response.body);
        print('Feedback submitted successfully!');
        print(data);
      } else {
        print('Failed to submit feedback. Server error.');
      }
    } catch (e) {
      print('Failed to submit feedback. Network error: $e');
    }
  }

  Future<List<Course>> fetchCourses() async {
    const url = 'http://68.183.83.189/api/programData';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body)['data'] as List;
        List<Course> _courses =
            responseData.map((data) => Course.fromJson(data)).toList();
        //notifyListeners();
        return _courses;
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<List<StudioData>> fetchStudioData() async {
    const String url = 'https://divinesoulyoga.in/api/studioData';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        return data.map((json) => StudioData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load studio data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<AttendedEvent>> attendEvent(String userId) async {
    try {
      final url =
          Uri.parse('https://divinesoulyoga.in/api/get-user-events/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print(jsonResponse);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((event) => AttendedEvent.fromJson(event)).toList();
      } else {
        throw Exception('Failed to load events: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('An error occurred: $e');
      return [];
    }
  }

  // Future<List<AttendedEvent>> attendEvent(String userId) async {
  //   print("Usei Id : ${userId}");
  //   try {
  //     final url = Uri.parse('https://divinesoulyoga.in/api/get-user-events/$userId');
  //     final response = await http.get(url);
  //
  //     if (response.statusCode == 200) {
  //       print('eventData api called.................  ${response.body}');
  //       // Decode the response body to JSON format
  //      // final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       final List<dynamic> jsonResponse = json.decode(response.body)['data'];
  //       return jsonResponse
  //           .map((event) => AttendedEvent.fromJson(event))
  //           .toList();
  //       // Convert the 'data' part of the JSON response to a List<Event>
  //      // List<BookEventsResponse> events = EventModel.listFromJson(jsonResponse['data']);
  //     //  return events;
  //     } else {
  //       print('Failed to load events: ${response.reasonPhrase}');
  //       return [];
  //     }
  //   } catch (e) {
  //     print('An error occurred: $e');
  //     return [];
  //   }
  // }

  Future<List<EventModel>> eventData(String userId) async {
    print("Usei Id : ${userId}");
    try {
      final url = Uri.parse('https://divinesoulyoga.in/api/eventsData/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('eventData api called.................  ${response.body}');
        // Decode the response body to JSON format
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Convert the 'data' part of the JSON response to a List<Event>
        List<EventModel> events = EventModel.listFromJson(jsonResponse['data']);
        return events;
      } else {
        print('Failed to load events: ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      print('An error occurred: $e');
      return [];
    }
  }

  Future ourteamData() async {
    try {
      final url = Uri.parse('http://68.183.83.189/api/ourteamData');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('ourteamData api called.................  ${response.body}');
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['data'];
      } else {
        print('Failed to load ourteam: ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      print('An error occurred: $e');
      return [];
    }
  }

  Future aboutData() async {
    try {
      final url = Uri.parse('http://68.183.83.189/api/aboutData');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('aboutData api called.................  ${response.body}');
        // Decode the response body to JSON format
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Convert the 'data' part of the JSON response to a List<Event>
        // List<OurTeam> ourteam =listFromJson(jsonResponse['data']);
        return jsonResponse['data'];
      } else {
        print('Failed to load about: ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      print('An error occurred: $e');
      return [];
    }
  }

  Future programData() async {
    try {
      final url = Uri.parse('https://divinesoulyoga.in/api/programtypeData');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('programsData api called.................  ${response.body}');
        // Decode the response body to JSON format
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Convert the 'data' part of the JSON response to a List<Event>
        // List<OurTeam> ourteam =listFromJson(jsonResponse['data']);
        return jsonResponse['data'];
      } else {
        print('Failed to load programs: ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      print('An error occurred: $e');
      return [];
    }
  }

  Future<void> updateUser(
      String name,
      String email,
      String id,
      String mobile,
      String city,
      String state,
      String address,
      String dob,
      File? profileImage) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://68.183.83.189/api/updateUser'),
    );

    // Adding form fields
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['id'] = id;
    request.fields['mobile'] = mobile;
    request.fields['city'] = city;
    request.fields['state'] = state;
    request.fields['address'] = address;
    request.fields['dob'] = dob;

    // Adding the profile image only if it's provided
    if (profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_image', profileImage.path),
      );
    }

    request.headers.addAll({
      "Content-Type": "multipart/form-data",
      "Accept": "application/json",
    });

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('User updated successfully. Response body: $responseBody');
      } else {
        String responseBody = await response.stream.bytesToString();
        print('Failed to update user. Status code: ${response.statusCode}');
        print('Response body (error): $responseBody');
      }
    } catch (e) {
      print('Error occurred while sending request: $e');
    }
  }

  Future<GalleryResponse?> fetchGalleryData() async {
    const String url = 'https://divinesoulyoga.in/api/gallerydata';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('API Response: $jsonResponse'); // Log the response for debugging
        return GalleryResponse.fromJson(
            jsonResponse); // Map the response to GalleryResponse model
      } else {
        throw Exception('Failed to load gallery data');
      }
    } catch (error) {
      print('Error fetching gallery data: $error');
    } finally {
      print('API call completed');
    }

    return null; // Return null if an error occurs or if the request fails
  }

  Future<TestimonialsResponse?> testimonialsData() async {
    try {
      final url = Uri.parse('https://divinesoulyoga.in/api/testimonialsData');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('eventData called.................  ${response.body}');
        // Decode the response body to JSON format
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print(
            'JSON Response: $jsonResponse'); // Add this line to check the structure of the response

        return TestimonialsResponse.fromJson(jsonResponse);
      } else {
        print('Failed to load testimonials: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('An error occurred: $e');
      return null;
    }
  }

  Future<List<BlogModel>> blogData() async {
    final response =
        await http.get(Uri.parse('https://divinesoulyoga.in/api/blogsData'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((blog) => BlogModel.fromJson(blog))
          .toList();
    } else {
      throw Exception("Failed to load blogs");
    }
  }
  //
  // Future<List<BlogModel>> blogData() async {
  //   try {
  //     final url = Uri.parse('https://divinesoulyoga.in/api/blogsData');
  //     final response = await http.get(url);
  //
  //     if (response.statusCode == 200) {
  //       print('eventData   called.................  ${response.body}');
  //       // Decode the response body to JSON format
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       print(jsonResponse['data']);
  //
  //       // Convert the 'data' part of the JSON response to a List<Event>
  //       List<BlogModel> blogs = BlogModel.listFromJson(jsonResponse['data']);
  //       return blogs;
  //     } else {
  //       print('Failed to load events: ${response.reasonPhrase}');
  //       return [];
  //     }
  //   } catch (e) {
  //     print('An error occurred: $e');
  //     return [];
  //   }
  // }

  Future<Map<String, dynamic>> postProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var headers = {
      'Cookie':
          'XSRF-TOKEN=eyJpdiI6IlgvR1YzRG81NzF1S2dLbTZEb0trOGc9PSIsInZhbHVlIjoiTjY0ZVJFVVBSWjBsUy9hRVNraHRXY2UxQmV6eEcrQlNyRk54NVdYNllkanhpUjJlb3dkeGs5OHIyL3VacVNtVFpPcHpleWdZdHlyMHErU0d4UWlYdEZBOXNmVmExREpwajZKRGlBanVnKzA3WWhLY3Q0ZDk3anRsTU0vNy95ZkoiLCJtYWMiOiI3OTYwY2I3MGVkN2Q2NTU0ZjBkNmJmYjk5ZmUwNjVjOGE0NWY2MzZmNmY5MDU3NmE4MjkxMjcxNGE4YzViM2NlIiwidGFnIjoiIn0%3D; laravel_session=eyJpdiI6Im9hVU10Qkd6YWhPL1RQYnVVZmRWTEE9PSIsInZhbHVlIjoiR0Vleit5bGNsM29tdmo0cEp2aHI4QU5yN3lmOHNUVU40ejhPTzVTZmJCTWwxdTkvVlNvcGt2dzF4NGpUWHZOYlpGNEVtdmhianVQL2dYMUE1MDcybzFDaENMUU9sM2Z2Z1FSTFRQSXg4WWZ4UFpZcE50L3pobDBpMWtYcmR2d08iLCJtYWMiOiI0MzdhODM4YmRlMzA0MmYzNWRjMGExMDgzMGEwZDk0MDI5Mjc1YzhiMzA3OWViYWFjNmNkYzc0N2ZhMzlmYTBkIiwidGFnIjoiIn0%3D'
    };

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://68.183.83.189/api/getProfile'));

    String? userId = prefs.getString('user_id');
    if (userId == null) {
      return {
        'success': false,
        'message': 'User ID not found in SharedPreferences'
      };
    }

    // Add fields to the request
    request.fields.addAll({'id': userId});

    // Add headers to the request
    request.headers.addAll(headers);

    try {
      // Send the request
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(responseBody);
        print(decodedResponse);
        return {'success': true, 'data': decodedResponse};
      } else {
        return {
          'success': false,
          'message': 'Failed to post data: ${response.reasonPhrase}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error sending request: $e'};
    }
  }
}
