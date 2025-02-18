import 'dart:convert';
import 'package:divine_soul_yoga/home_screen/course_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListOfDays extends StatefulWidget {
  final courseId;
  const ListOfDays({super.key, this.courseId});

  @override
  State<ListOfDays> createState() => _ListOfDaysState();
}

class _ListOfDaysState extends State<ListOfDays> {
  List<String> days = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDays();
  }

  Future<void> fetchDays() async {
    try {
      final response = await http.get(
          Uri.parse('https://divinesoulyoga.in/api/day/${widget.courseId}'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'];

        // Extract unique day values
        final Set<String> uniqueDays =
            data.map((item) => item['day'].toString()).toSet();

        setState(() {
          days = uniqueDays.toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load days');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching days: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Days List',
          style: TextStyle(color: Color(0xffD45700)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: days.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailsScreen(
                          days: days[index],
                          courseId: widget.courseId.toString(),
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Card(
                      child: ListTile(
                        title: Text('Day ${days[index]}'),
                        leading: const Icon(
                          Icons.folder,
                          color: Color(0xffD45700),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
