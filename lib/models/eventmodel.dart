class EventModel {
  final int id;
  final String description;
  final String startDatetime;
  final String endDatetime;
  final String image;
  final String status;
  final String title;
  final int stateId;
  final String location;
  final String trainer;
  final String amount;
  final String contactNumber;
  final bool paid;

  EventModel({
    required this.id,
    required this.description,
    required this.startDatetime,
    required this.endDatetime,
    required this.image,
    required this.status,
    required this.title,
    required this.stateId,
    required this.location,
    required this.trainer,
    required this.amount,
    required this.contactNumber,
    required this.paid,

  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      description: json['description'],
      startDatetime: json['start_datetime'],
      endDatetime: json['end_datetime'],
      image: json['image'],
      status: json['status'],
      title: json['title'],
      stateId: json['state_id'],
      location: json['location'],
      trainer: json['trainer'],
      amount: json['amount'],
      contactNumber: json['contact_number'],
      paid: json['paid']
    );
  }

  // Add this method to convert a list of JSON objects into a list of EventModel objects
  static List<EventModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => EventModel.fromJson(json)).toList();
  }
}
