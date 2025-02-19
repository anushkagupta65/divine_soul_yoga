class StudioData {
  final int id;
  final String title;
  final String contactNumber;
  final String location;
  final String details;
  final String address;
  final String createdAt;
  final String updatedAt;

  StudioData({
    required this.id,
    required this.title,
    required this.contactNumber,
    required this.location,
    required this.details,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to parse JSON into a StudioData object
  factory StudioData.fromJson(Map<String, dynamic> json) {
    return StudioData(
      id: json['id'],
      title: json['title'],
      contactNumber: json['contact_number'],
      location: json['location'],
      details: json['details'],
      address: json['address'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
