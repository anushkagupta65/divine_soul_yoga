import 'package:divine_soul_yoga/src/api_service/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class OurTeam extends StatefulWidget {
  const OurTeam({super.key});

  @override
  State<OurTeam> createState() => _OurteamState();
}

class _OurteamState extends State<OurTeam> {
  List? ourteamData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getOurTeamData();
  }

  Future<void> getOurTeamData() async {
    ourteamData = await ApiService().ourteamData();

    setState(() {
      isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      // height: MediaQuery.of(context).size.height * 0.40,
                      // width: MediaQuery.of(context).size.width,
                      child: Stack(
                        //alignment: Alignment.topLeft,
                        children: [
                          Image.network(
                            'http://68.183.83.189/${ourteamData![0]["image"].toString()}',
                            fit: BoxFit.fill,
                            width: MediaQuery.of(context).size.width,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 25, left: 20),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back, // The back arrow icon (←)
                                size: 35.0, // Adjust the size if needed
                                color: Color(
                                    0xffffffff), // You can change the color
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Color(0xffD45700).withOpacity(0.9),
                      height: MediaQuery.of(context).size.height * 0.60,
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 25),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Image.asset(
                                'assets/images/lf1.png', // Replace with your image path
                                width: 100,
                              ),
                            ),
                          ),
                          // Bottom-left image
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Image.asset(
                              'assets/images/lf2.png', // Replace with your image path
                              width: 200, // Adjust size as needed
                              height: 200, // Adjust size as needed
                            ),
                          ),
                          // Text over the screen
                          Center(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 40.0),
                                    child: Text(
                                      ourteamData![0]["title"],
                                      style: TextStyle(
                                          fontSize: 38,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Html(
                                      data: ourteamData![0]["description"],
                                      style: {
                                        "body": Style(
                                          fontSize: FontSize(
                                              16), // Adjust the font size as needed
                                          color: Colors
                                              .white, // Set a custom text color if desired
                                          fontWeight: FontWeight
                                              .normal, // Optional: Adjust the weight
                                        ),
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
