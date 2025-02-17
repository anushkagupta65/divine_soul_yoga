import 'dart:io';
import 'package:divine_soul_yoga/api_service/apiservice.dart';
import 'package:divine_soul_yoga/models/gallerymmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<GalleryItem>? galleryData;

  @override
  void initState() {
    super.initState();
    loadGallery();
  }

  void loadGallery() async {
    GalleryResponse? galleryResponse = await ApiService().fetchGalleryData();

    if (galleryResponse != null && galleryResponse.data.isNotEmpty) {
      setState(() {
        galleryData = galleryResponse.data;
      });
    } else {
      print('Failed to load gallery data');
    }
  }

  _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: galleryData != null && galleryData!.isNotEmpty ?
      Column(
        children: [
          // Check if galleryData is not null and contains data
         // if (galleryData != null && galleryData!.isNotEmpty)
            ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: galleryData!.length,
              shrinkWrap: true, // Ensures the list doesn't take more space than required
              physics: NeverScrollableScrollPhysics(), // Disables scrolling
              itemBuilder: (context, index) {
                var galleryItem = galleryData![index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        galleryItem.title, // Display title dynamically
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(253, 96, 5, 1)
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Add space between the cards

                    // Check if gallery.images has at least 3 images before displaying them
                    if (galleryItem.images.isNotEmpty)
                      SizedBox(
                        height: 210,
                        child: Card(
                          child: Row(
                            children: [
                              // First image taking half of the screen
                              Expanded(
                                flex: 1,
                                child: galleryItem.images.isNotEmpty
                                    ? GestureDetector(
                                  onTap: () {
                                    _showFullScreenImage(
                                        context,
                                        galleryItem.images[0].imageUrl);
                                  },
                                  child: Image.network(
                                    "https://divinesoulyoga.in/${galleryItem.images[0].imageUrl}",
                                    fit: BoxFit.cover,
                                    height: double.infinity, // Ensure height is set
                                  ),
                                )
                                    : Container(), // Fallback if no image
                              ),
                              // Second half containing two images
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    galleryItem.images.length > 1
                                        ? GestureDetector(
                                      onTap: () {
                                        _showFullScreenImage(
                                            context,
                                            "${galleryItem.images[1].imageUrl}");
                                      },
                                      child: Image.network(
                                        "https://divinesoulyoga.in/${galleryItem.images[1].imageUrl}",
                                        fit: BoxFit.cover,
                                        height: 100, // Set a fixed height for the image
                                      ),
                                    )
                                        : Container(),
                                    galleryItem.images.length > 2
                                        ? GestureDetector(
                                      onTap: () {
                                        _showFullScreenImage(
                                            context,
                                            "${galleryItem.images[2].imageUrl}");
                                      },
                                      child: Image.network(
                                        "https://divinesoulyoga.in/${galleryItem.images[2].imageUrl}",
                                        fit: BoxFit.cover,
                                        height: 100, // Set a fixed height for the image
                                      ),
                                    )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      )
          :  Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      )
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: PhotoView(
            imageProvider: NetworkImage("https://divinesoulyoga.in/${imageUrl}"),
            backgroundDecoration: BoxDecoration(color: Colors.black),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3.0,
            initialScale: PhotoViewComputedScale.contained,
            //scaleStateCycle: false, // Prevents transformations from causing layout issues
          ),
        ),
      ),
    );
  }
}
