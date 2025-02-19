import 'package:auto_size_text/auto_size_text.dart';
import 'package:divine_soul_yoga/src/api_service/apiservice.dart';
import 'package:divine_soul_yoga/src/presentation/home/home_drawer_widget.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/course_overview.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/home_screen.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/subscription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Programtab extends StatefulWidget {
  const Programtab({super.key});

  @override
  State<Programtab> createState() => _ProgramtabState();
}

class _ProgramtabState extends State<Programtab> with TickerProviderStateMixin {
  List? arrProgramData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    programData();
  }

  Future<void> programData() async {
    arrProgramData = await ApiService().programData();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 56.h,
                    margin: EdgeInsets.all(8.sp),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 250, 164, 72),
                          Color.fromARGB(255, 232, 62, 11),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 8.r,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: AutoSizeText(
                        textAlign: TextAlign.center,
                        maxFontSize: 22,
                        minFontSize: 22,
                        "Subscribe & Transform",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  itemCount: arrProgramData!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () {
                            debugPrint(
                                "Progarms Lang: ${arrProgramData![index]['id'].toString()}");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseOverviewScreen(
                                  type: arrProgramData![index]['id'].toString(),
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Image.network(
                                'https://divinesoulyoga.in/${arrProgramData![index]['image']}',
                                fit: BoxFit.fill,
                                width: MediaQuery.of(context).size.width,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 5, top: 20),
                                child: SizedBox(
                                  width: 200,
                                  child: Text(
                                    arrProgramData![index]['name'],
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xffFFFFFF)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Center(
                  child: Text(
                    'Happiness & divine love is in air!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffD45700)),
                  ),
                ),
                SizedBox(
                  height: 12.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: iconText(
                        "Bliss\nMeditation",
                        "Meditation is a mental training practice that teaches you to slow down racing thoughts.",
                        'assets/images/mp1.png',
                      ),
                    ),
                    Expanded(
                      child: iconText(
                        "Divine\nhealing",
                        "Becoming more aware of the present moment can help us enjoy the world around us.",
                        'assets/images/mp2.png',
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    iconText(
                      "Laughter\ntherapy",
                      "The body is of utmost importance for our holistic health as it is here that the mental and spiritual realms reside.",
                      'assets/images/mp3.png',
                    ),
                    iconText(
                      "Yoga\nAsana​",
                      "The body is of utmost importance for our holistic health as it is here that the mental and spiritual realms reside.",
                      'assets/images/mp3.png',
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Card(
                    elevation: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffffffff),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: const Column(
                        children: [
                          SizedBox(
                            height: 25,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
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
                            padding: EdgeInsets.all(20.0),
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
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                  child: Card(
                    elevation: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffffffff),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: const ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(30.0),
                                child: AutoSizeText(
                                  minFontSize: 20,
                                  maxFontSize: 24,
                                  "Testimonials",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff000000)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.h),
                            child: Container(
                              // color: Colors.black,
                              alignment: Alignment.centerLeft,
                              child: const Image(
                                image: AssetImage(
                                  "assets/images/its.png",
                                ),
                              ),
                            ),
                          ),
                          SwipeableCard()
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget iconText(String title, String description, String iconPath) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Card(
        elevation: 2,
        child: SizedBox(
          width: 144.w,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10.w, top: 10.h),
                child: Row(
                  children: [
                    Image.asset(
                      iconPath,
                      fit: BoxFit.cover,
                      width: 48.w,
                    ),
                    SizedBox(
                      width: 6.w,
                    ),
                    AutoSizeText(
                      maxFontSize: 12,
                      minFontSize: 12,
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff000000)),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.sp),
                child: AutoSizeText(
                  description,
                  maxFontSize: 12,
                  minFontSize: 12,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
