import 'dart:ui';

import 'package:divine_soul_yoga/api_service/apiservice.dart';
import 'package:divine_soul_yoga/home_screen/blog_detail.dart';
import 'package:divine_soul_yoga/models/blogmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';

class Blog extends StatefulWidget {
  const Blog({super.key});

  @override
  State<Blog> createState() => _BlogState();
}

class _BlogState extends State<Blog> {
  List<BlogModel>? blogData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getBlogData();
  }

  Future<void> getBlogData() async {
    blogData = await ApiService().blogData();
    print('getblogdata called................................ $blogData');
    print(
        'getblogdata called................................ ${blogData?.first.title}');
    setState(() {
      isLoading = false;
    });
  }

  // final List<Map<String, String>> items = [
  //   {
  //     "image": "assets/images/yg1.png",
  //     "text": "5 Ways Meditation Makes Us Better at Yoga",
  //   },
  //   {
  //     "image": "assets/images/yg2.png",
  //     "text": "Yin Yoga: Devotion and Love to warm our hearts"
  //   },
  //   {
  //     "image": "assets/images/yg3.png",
  //     "text": "Tapas – sparking AND tending your inner fire with care"
  //   },
  //   // {"image": "https://via.placeholder.com/150", "text": "Item 4"},
  // ];
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Blogs',
          style: TextStyle(color: Color(0xffD45700)),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loader while fetching data
          : blogData == null || blogData!.isEmpty
          ? Center(child: Text("No blogs available")) // Handle no data case
          : SingleChildScrollView(
        child: Column(
          children: [
            // Display the first blog image (if applicable)
            Image.network(
              'https://divinesoulyoga.in/${blogData![0].image}',
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
            ),

            // List of blogs
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.025,
              ),
              child: ListView.separated(
                itemCount: blogData!.length,
                shrinkWrap: true, // Prevents ListView from taking infinite height
                physics: NeverScrollableScrollPhysics(), // Disables its own scroll
                separatorBuilder: (context, i) => SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlogDetail({
                            "title": blogData![index].title,
                            "description": blogData![index].description,
                            "image":
                            'http://68.183.83.189/${blogData![index].image}',
                          }),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width * 0.025,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Blog image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              "https://divinesoulyoga.in/${blogData![index].image}",
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.image,
                                    size: 100, color: Colors.grey);
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          // Blog title
                          Expanded(
                            child: Html(
                              data: blogData![index].title,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
