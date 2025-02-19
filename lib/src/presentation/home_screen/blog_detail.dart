import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class BlogDetail extends StatefulWidget {
  final Map blog; // Map to hold blog data
  BlogDetail(this.blog);

  @override
  State<BlogDetail> createState() => _BlogDetailState();
}

class _BlogDetailState extends State<BlogDetail> {
  get blogData => null;

  @override
  Widget build(BuildContext context) {
    // Retrieve data from the passed map
    final String imageUrl = widget.blog['image'];
    final String title = widget.blog['title'];
    final String description = widget.blog['description'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Details',style: TextStyle(color: Color(0xffD45700)),),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),

            // Title section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Description section
            Row(
              children: [
               // const Icon(Icons.description, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Html(
                   data: description,
                    // style: const TextStyle(
                    //   fontSize: 16,
                    //   color: Colors.grey,
                    // ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Address section
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Icon(Icons.home, color: Colors.blue),
            //       const SizedBox(width: 8),
            //       Expanded(
            //         child: Text(
            //           address,
            //           style: const TextStyle(
            //             fontSize: 16,
            //             color: Colors.grey,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
