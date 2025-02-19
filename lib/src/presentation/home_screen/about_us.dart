import 'package:divine_soul_yoga/src/api_service/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  List? aboutData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getaboutData();
  }

  Future<void> getaboutData() async {
    aboutData = await ApiService().aboutData();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        'http://68.183.83.189/${aboutData![0]["image"].toString()}',
                        fit: BoxFit.fill,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ],
                  ),
                  Container(
                    transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                    child: const CircleAvatar(
                      radius: 50.0,
                      backgroundImage: AssetImage('assets/images/impro1.png'),
                    ),
                  ),
                  Container(
                    child: Text(
                      aboutData![0]["title"],
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                          color: Color.fromRGBO(253, 96, 5, 1)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Html(data: aboutData![0]["description"]),
                  ),
                  const SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
    );
  }
}
