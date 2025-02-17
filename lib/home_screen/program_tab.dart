import 'package:divine_soul_yoga/api_service/apiservice.dart';
import 'package:divine_soul_yoga/home_screen/course_overview.dart';
import 'package:divine_soul_yoga/home_screen/home_screen.dart';
import 'package:divine_soul_yoga/home_screen/list_of_days.dart';
import 'package:divine_soul_yoga/home_screen/meditation_course_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Programtab extends StatefulWidget {
  const Programtab({super.key});

  @override
  State<Programtab> createState() => _ProgramtabState();
}

class _ProgramtabState extends State<Programtab> with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  List? arrProgramData = [];
  bool isLoading = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    programData();

    // Replace the below videoId with the actual YouTube video ID
    // _controller = YoutubePlayerController(
    //   initialVideoId: 'RYMAkz8WUUI',
    //   flags: YoutubePlayerFlags(
    //     hideThumbnail: false,
    //     autoPlay: false,
    //     mute: false,
    //   ),
    // );
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> programData() async {
    arrProgramData = await ApiService().programData();

    setState(() {
      isLoading = false;
    });
  }

  // int _selectedIndex = 0;
  // late YoutubePlayerController _controller;
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: arrProgramData!.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          print(
                              "Progarms Lang: ${arrProgramData![index]['id'].toString()}");
                          Navigator.push(
                              context,
                              MaterialPageRoute(

                                  //builder: (context) => MeditationCourseList(id: 2)));
                                  builder: (context) =>
                                      // ListOfDays(courseId: arrProgramData![index]['id'].toString(),)
                                      CourseOverviewScreen(
                                        type: arrProgramData![index]['id']
                                            .toString(),
                                      )));

                          // print('http://68.183.83.189/${arrProgramData![i]["image"].toString()}');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                              //alignment: AlignmentDirectional.center,
                              children: [
                                Image.network(
                                  //color: Colors.black.withOpacity(1.0),
                                  'https://divinesoulyoga.in/${arrProgramData![index]['image']}',
                                  fit: BoxFit.fill,
                                  width: MediaQuery.of(context).size.width,
                                  //height: MediaQuery.of(context).size.height * 0.2,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 5, top: 20),
                                  child: Container(
                                    width: 200,
                                    child: Text(
                                      arrProgramData![index]['name'],
                                      //arrProgramData![i]["title"],
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xffFFFFFF)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              ]),
                        ),
                      ),
                    );
                  }),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  'Happiness & divine love is in air!',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffD45700)),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Card(
                      elevation: 5,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 10),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/mp1.png', // Replace with your image path
                                    fit: BoxFit.cover, width: 55,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Bliss\n Meditation",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff000000)),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Text(
                                  "Meditation is a mental training practice that teaches you to slow down racing thoughts."),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Card(
                      elevation: 5,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 10),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/mp2.png', // Replace with your image path
                                    fit: BoxFit.cover, width: 55,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Divine\n healing",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff000000)),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Text(
                                  "Becoming more aware of the present moment can help us enjoy the world around us."),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Card(
                      elevation: 5,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 10),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/mp3.png', // Replace with your image path
                                    fit: BoxFit.cover, width: 65,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Laughter \ntherapy   ",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff000000)),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Text(
                                  "The body is of utmost importance for our holistic health as it is here that the mental"),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Card(
                      elevation: 5,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 10),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/mp3.png', // Replace with your image path
                                    fit: BoxFit.cover, width: 65,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Yoga\n Asana​   ",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff000000)),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                  "The body is of utmost importance for our holistic health as it is here that the mental and spiritual realms reside."),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 3,
                  child: Container(
                    // padding: const EdgeInsets.only(
                    // top: 10, right: 20, left: 20, bottom: 20),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            "Let's create a new world of love with Dr. Deepak Mittal !​",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff000000),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            "Originated in the foothills of the Himalayas, Divine Soul Yoga is an oasis of love, peace, and harmony!Our beloved master, Dr. Deepak Mittal has specially curated a holistic life-altering wellness solution. At Divine Soul Yoga, the ancient science of life and its secret treasures are revealed with soul-enriching meditation retreats in the lap of nature.Authentic yoga is taught by well-qualified yoga experts.",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                                color: Color(0xff666666),
                                height: 0),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xffffffff),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 3,
                  child: Container(
                    // padding: const EdgeInsets.only(
                    // top: 10, right: 20, left: 20, bottom: 20),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)),
                            // child: Image(
                            //   image: AssetImage("assets/images/img1.png"),
                            //   fit: BoxFit.cover,
                            //   // width: MediaQuery.of(context).size.width,
                            // ),
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Text(
                                "Testimonials",
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff000000)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Container(
                            // color: Colors.black,
                            alignment: Alignment.centerLeft,
                            child: Image(
                              image: AssetImage(
                                "assets/images/its.png",
                              ),
                              // style: TextStyle(
                              //   fontSize: 20,
                              //   fontWeight: FontWeight.w400,
                              //   color: Color(0xff000000),
                              // ),
                            ),
                          ),
                        ),
                        SwipeableCard()
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xffffffff),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              ),
            ],
          );
  }
}
