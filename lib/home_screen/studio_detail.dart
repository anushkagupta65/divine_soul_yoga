import 'package:flutter/material.dart';

import '../models/studio_model.dart';

class StudioDetails extends StatefulWidget {
  final StudioData studioData;

  const StudioDetails({super.key, required this.studioData});

  @override
  State<StudioDetails> createState() => _StudioDetailsState();
}

class _StudioDetailsState extends State<StudioDetails> {
  @override
  Widget build(BuildContext context) {
    // Example data for image, title, location, and address
    final String imageUrl = 'https://via.placeholder.com/300';
    final String title = 'Yoga Studio';
    final String location = '123 Main Street, New York, USA';
    final String address = 'Suite 200, Second Floor, Building ABC';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Image.network(
              'https://picsum.photos/200/300',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),

            // Title section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.studioData.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Location section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.studioData.address,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Address section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.home, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
