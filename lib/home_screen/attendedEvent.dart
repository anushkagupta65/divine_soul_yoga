import 'package:divine_soul_yoga/home_screen/attended_event_details.dart';
import 'package:divine_soul_yoga/home_screen/event_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_service/apiservice.dart';
import '../models/atttendedevent.dart';

class Attendedevent extends StatefulWidget {
  final String userId;
  const Attendedevent({super.key, required this.userId});

  @override
  State<Attendedevent> createState() => _AttendedeventState();
}

class _AttendedeventState extends State<Attendedevent> {
  List<AttendedEvent>? eventData;
  bool isLoading = true;

  String formatTime(String? datetime) {
    if (datetime == null || datetime.isEmpty) return 'N/A';
    try {
      final parsedDate = DateTime.parse(datetime);
      return DateFormat('hh:mm a').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String formatDate(String datetime) {
    final parsedDate = DateTime.parse(datetime); // Parse string to DateTime
    return DateFormat('MMM dd yyyy').format(parsedDate); // Format to "Jan 11 2024"
  }


  @override
  void initState() {
    super.initState();
    getEventData();
  }

  Future<void> getEventData() async {
    try {
      eventData = await ApiService().attendEvent(widget.userId);
    } catch (error) {
      print('Error fetching event data: $error');
      eventData = [];
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemWidth = MediaQuery.of(context).size.width / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attended Events",
          style: TextStyle(
            color: Color(0xffD45700),
          ),
        ),
      ),
      body: isLoading
          ? Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      )
          : (eventData == null || eventData!.isEmpty)
          ? Center(
            child: const Text(
                    "No events available",
                    style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
                    ),
                  ),
          )
          : SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: eventData!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.70,
            ),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendedEventDetails(eventData: eventData)
                    ),
                  );                },
                child: SizedBox(
                  width: itemWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      elevation: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xffD45700),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  eventData![index].image != null &&
                                      eventData![index].image!.isNotEmpty
                                      ? 'https://divinesoulyoga.in/${eventData![index].image}'
                                      : 'https://via.placeholder.com/150',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.image_not_supported),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 8),
                                child: Text(
                                  eventData![index].title ?? 'No Title Available',
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff000000),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    CupertinoIcons.location_solid,
                                    size: 15,
                                    color: Color(0xffD45700),
                                  ),
                                  Expanded(
                                    child: Text(
                                      eventData![index].location ??
                                          'No Location Provided',
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w300,
                                        color: Color(0xffD45700),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              //const SizedBox(height: 8),
                              Text(
                                '${formatDate(eventData![index].startDatetime.toString())}',
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${formatTime(eventData![index].startDatetime.toString())} To ${formatTime(eventData![index].endDatetime.toString())}',
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                              // const Spacer(),
                              // Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: SizedBox(
                              //     width: itemWidth * 0.5,
                              //     height: itemWidth * 0.2,
                              //     child: ElevatedButton(
                              //       style: ElevatedButton.styleFrom(
                              //         backgroundColor: const Color(0xffD45700),
                              //         foregroundColor: const Color(0xffFFFFFF),
                              //         padding: const EdgeInsets.symmetric(
                              //           vertical: 10,
                              //           horizontal: 5,
                              //         ),
                              //         shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.circular(10),
                              //         ),
                              //       ),
                              //       onPressed: () {
                              //         // Handle button press
                              //       },
                              //       child: Text(
                              //         _getButtonLabel(
                              //             eventData![index].status?.toString()),
                              //         style: const TextStyle(
                              //           fontSize: 12,
                              //         ),
                              //         maxLines: 1,
                              //         overflow: TextOverflow.ellipsis,
                              //         textAlign: TextAlign.center,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getButtonLabel(String? status) {
    switch (status) {
      case 'Active':
        return 'Attend';
      case 'Pending':
        return 'Coming Soon';
      case 'Completed':
        return 'Ended';
      default:
        return 'Event';
    }
  }
}

