class AttendedEvent {
  final int id;
  final String? title;
  final String? description;
  final String? image;
  final String? location;
  final String? status;
  final String? startDatetime;
  final String? endDatetime;
  final String? trainer;
  final String? amount;
  final String? contactNumber;

  AttendedEvent(
      {required this.id,
      this.title,
      this.description,
      this.image,
      this.location,
      this.status,
      this.startDatetime,
      this.endDatetime,
      this.amount,
      this.contactNumber,
      this.trainer});

  factory AttendedEvent.fromJson(Map<String, dynamic> json) {
    return AttendedEvent(
        id: json['event']['id'],
        title: json['event']['title'] ?? 'No Title Available',
        description: json['event']['description'] ?? 'No Description Available',
        image: json['event']['image'], // Can be null
        location: json['event']['location'] ?? 'No Location Provided',
        status: json['event']['status'] ?? 'Unknown',
        startDatetime: json['event']['start_datetime'], // Can be null
        endDatetime: json['event']['end_datetime'], // Can be null
        trainer: json['event']['trainer'],
        contactNumber: json['event']['contact_number'],
        amount: json['event']['amount']);
  }
}
