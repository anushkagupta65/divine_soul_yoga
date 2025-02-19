class UserProfile {
  final int id;
  final String? name;
  final String mobile;
  final DateTime? dob;
  final String email;
  final String? city;
  final String? state;
  final String? address;

  UserProfile({
    required this.id,
    this.name,
    required this.mobile,
    this.dob,
    required this.email,
    this.city,
    this.state,
    this.address,
  });

  // Factory method to create a UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      name: json['name'] as String?,
      mobile: json['mobile'] as String,
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      email: json['email'] as String,
      city: json['city'] as String?,
      state: json['state'] as String?,
      address: json['address'] as String?,
    );
  }

  // Method to convert UserProfile instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'dob': dob?.toIso8601String(),
      'email': email,
      'city': city,
      'state': state,
      'address': address,
    };
  }
}
