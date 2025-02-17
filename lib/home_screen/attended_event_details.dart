import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

import '../models/atttendedevent.dart';

class AttendedEventDetails extends StatefulWidget {
  final List<AttendedEvent>? eventData;
  const AttendedEventDetails({super.key, required this.eventData});

  @override
  State<AttendedEventDetails> createState() => _AttendedEventDetailsState();
}

class _AttendedEventDetailsState extends State<AttendedEventDetails> {
  late Timer _timer;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();

    // Initialize the remaining time by calculating the difference from now
    _remainingTime = DateTime.parse(widget.eventData![0].startDatetime.toString()).difference(DateTime.now());

    // Update the remaining time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = DateTime.parse(widget.eventData![0].startDatetime.toString()).difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return "Event Expired";
    }
    String days = duration.inDays > 0 ? "${duration.inDays}d " : "";
    String hours = (duration.inHours % 24) > 0 ? "${(duration.inHours % 24)}h " : "";
    String minutes = (duration.inMinutes % 60) > 0 ? "${(duration.inMinutes % 60)}m " : "";
    String seconds = (duration.inSeconds % 60) > 0 ? "${(duration.inSeconds % 60)}s" : "";
    return "$days$hours$minutes$seconds";
  }

  String formatDate(String datetime) {
    final parsedDate = DateTime.parse(datetime); // Parse string to DateTime
    return DateFormat('MMM dd yyyy').format(parsedDate); // Format to "Jan 11 2024"
  }

  String formatTime(String datetime) {
    final parsedDate = DateTime.parse(datetime); // Parse string to DateTime
    return DateFormat('hh:mm a').format(parsedDate); // Format to time (e.g., 01:02 AM)
  }

  @override
  Widget build(BuildContext context) {
    String countdown = _formatDuration(_remainingTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Event Details",
          style: TextStyle(
            color: Color(0xffD45700),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color:const Color(0xffD45700),
              height: MediaQuery.of(context).size.height * 0.25,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(widget.eventData![0].title.toString(), style: const TextStyle(fontSize: 18, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text("${formatDate(widget.eventData![0].startDatetime.toString())} to ${formatDate(widget.eventData![0].endDatetime.toString())}", style: TextStyle(fontSize: 12, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text("${formatTime(widget.eventData![0].startDatetime.toString())} to ${formatTime(widget.eventData![0].endDatetime.toString())}", style: TextStyle(fontSize: 12, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text("$countdown", style: const TextStyle(fontSize: 18, color: Colors.white)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network('https://divinesoulyoga.in/${widget.eventData![0].image}'),
              ),
            ),

             const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Html(data: widget.eventData![0].description),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Html(data: 'Trainer: ${widget.eventData![0].trainer}'),
                  Html(data: 'Joining Fee: ${widget.eventData![0].amount}'),
                  Html(data: 'Venue: ${widget.eventData![0].location}'),
                  Html(data: 'Contact Number: ${widget.eventData![0].contactNumber}'),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
