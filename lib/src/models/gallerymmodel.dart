class GalleryResponse {
  final String message;
  final List<GalleryItem> data;

  GalleryResponse({required this.message, required this.data});

  factory GalleryResponse.fromJson(Map<String, dynamic> json) {
    return GalleryResponse(
      message: json['message'],
      data: List<GalleryItem>.from(
          json['data'].map((item) => GalleryItem.fromJson(item))),
    );
  }
}

class GalleryItem {
  final int id;
  final String title;
  final List<GalleryImage> images;

  GalleryItem({required this.id, required this.title, required this.images});

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id'],
      title: json['title'],
      images: List<GalleryImage>.from(
          json['images'].map((item) => GalleryImage.fromJson(item))),
    );
  }
}

class GalleryImage {
  final int id;
  final int galleryId;
  final String imageUrl;

  GalleryImage(
      {required this.id, required this.galleryId, required this.imageUrl});

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['id'],
      galleryId: json['gallery_id'],
      imageUrl: json['gallery_image'],
    );
  }
}
