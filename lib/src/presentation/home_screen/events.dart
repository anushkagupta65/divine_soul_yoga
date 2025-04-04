import 'package:divine_soul_yoga/src/api_service/apiservice.dart';
import 'package:divine_soul_yoga/src/models/eventmodel.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/event_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Events extends StatefulWidget {
  final String userId;
  const Events({super.key, required this.userId});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  List<EventModel>? eventData;
  bool isLoading = true;
  String selectedCity = "Delhi";

  @override
  void initState() {
    super.initState();
    getEventData();
  }

  String formatTime(String datetime) {
    final parsedDate = DateTime.parse(datetime);
    return DateFormat('hh:mm a').format(parsedDate);
  }

  String formatDate(String datetime) {
    final parsedDate = DateTime.parse(datetime);
    return DateFormat('MMM dd yyyy').format(parsedDate);
  }

  Future<void> getEventData() async {
    try {
      final data = await ApiService().eventData(widget.userId);
      setState(() {
        eventData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        eventData = [];
        isLoading = false;
      });
      debugPrint('Error fetching events: $e');
    }
  }

  List<EventModel> getFilteredEvents() {
    if (selectedCity == null || eventData == null) {
      return eventData ?? [];
    }
    return eventData!
        .where((event) => event.location.toString().contains(selectedCity!))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final itemWidth = MediaQuery.of(context).size.width / 2;

    return Column(
      children: [
        // City selection buttons
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCityButton('Delhi'),
              _buildCityButton('Hoshiarpur'),
              _buildCityButton('Chandigarh'),
            ],
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        // Event list
        Center(
          child: isLoading
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : (eventData != null && getFilteredEvents().isNotEmpty)
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: getFilteredEvents().length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.62,
                        ),
                        itemBuilder: (context, index) {
                          final filteredEvents = getFilteredEvents();
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EventDetails(
                                            eventData: filteredEvents[index],
                                          )));
                            },
                            child: SizedBox(
                              width: itemWidth,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Card(
                                  elevation: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xffD45700)),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.network(
                                                'https://divinesoulyoga.in/${filteredEvents[index].image.toString()}',
                                                fit: BoxFit.cover,
                                              )),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, bottom: 8),
                                            child: Text(
                                              filteredEvents[index]
                                                  .title
                                                  .toString(),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                CupertinoIcons.location_solid,
                                                size: 15,
                                                color: Color(0xffD45700),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  filteredEvents[index]
                                                      .location
                                                      .toString(),
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
                                          Text(
                                            '${formatDate(filteredEvents[index].startDatetime.toString())}',
                                            style:
                                                const TextStyle(fontSize: 10),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${formatTime(filteredEvents[index].startDatetime.toString())} To ${formatTime(filteredEvents[index].endDatetime.toString())}',
                                            style:
                                                const TextStyle(fontSize: 10),
                                            textAlign: TextAlign.center,
                                          ),
                                          const Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              width: itemWidth * 0.5,
                                              height: itemWidth * 0.2,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xffD45700),
                                                  foregroundColor:
                                                      const Color(0xffFFFFFF),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 10,
                                                      horizontal: 5),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EventDetails(
                                                        eventData:
                                                            filteredEvents[
                                                                index],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  _getButtonLabel(
                                                      filteredEvents[index]
                                                          .status
                                                          .toString(),
                                                      filteredEvents,
                                                      index),
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
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
                    )
                  : Text(
                      "No events available for $selectedCity\nPlease check another city",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
        ),
      ],
    );
  }

  Widget _buildCityButton(String city) {
    bool isSelected = selectedCity == city;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCity = city;
        });
      },
      child: Container(
        width: 96,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: isSelected ? const Color(0xffD45700) : Colors.grey[300],
          border: Border.all(
            color: const Color(0xffD45700),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            city,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xffD45700),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

String _getButtonLabel(
    String status, List<EventModel> filteredEvents, int index) {
  if (filteredEvents[index].isExpired == 1) {
    return "Expired";
  }

  return switch (status) {
    'Active' => 'Attend',
    'Pending' => 'Coming Soon',
    'Completed' => 'Ended',
    _ => 'Event',
  };
}
