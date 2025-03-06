import 'dart:io';
import 'package:divine_soul_yoga/src/api_service/apiservice.dart';
import 'package:divine_soul_yoga/src/models/gallerymmodel.dart';
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
      child: galleryData != null && galleryData!.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: galleryData!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var galleryItem = galleryData![index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              galleryItem.title,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(253, 96, 5, 1)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (galleryItem.images.isNotEmpty)
                            SizedBox(
                              height: 210,
                              child: SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: galleryItem.images.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        _showFullScreenImage(context,
                                            galleryItem.images[index].imageUrl);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            "https://divinesoulyoga.in/${galleryItem.images[index].imageUrl}",
                                            fit: BoxFit.cover,
                                            width: 150,
                                            height: double.infinity,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            )
          : SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
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
            imageProvider:
                NetworkImage("https://divinesoulyoga.in/${imageUrl}"),
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
