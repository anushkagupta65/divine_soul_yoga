class BlogModel {
  final int id;
  final String title;
  final String description;
  final String image;

  BlogModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'] ?? '', // Add a fallback in case the image is null
    );
  }
}
