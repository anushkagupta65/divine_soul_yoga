// import 'dart:math';
// import 'dart:ui_web';
import 'package:divine_soul_yoga/api_service/apiservice.dart';
import 'package:divine_soul_yoga/home_screen/about_us.dart';
import 'package:divine_soul_yoga/home_screen/attendedEvent.dart';
import 'package:divine_soul_yoga/home_screen/blog.dart';
import 'package:divine_soul_yoga/home_screen/contact_us.dart';
import 'package:divine_soul_yoga/home_screen/events.dart';
import 'package:divine_soul_yoga/home_screen/feedback_screen.dart';
import 'package:divine_soul_yoga/home_screen/gallery.dart';
import 'package:divine_soul_yoga/home_screen/our_team.dart';
import 'package:divine_soul_yoga/home_screen/profile.dart';
import 'package:divine_soul_yoga/home_screen/program_tab.dart';
import 'package:divine_soul_yoga/home_screen/see_all.dart';
import 'package:divine_soul_yoga/home_screen/studio.dart';
import 'package:divine_soul_yoga/home_screen/subscription.dart';
import 'package:divine_soul_yoga/login/login.dart';
import 'package:divine_soul_yoga/models/testimonialsmodel.dart';
import 'package:divine_soul_yoga/models/usermodel.dart';
import 'package:divine_soul_yoga/provider/userprovider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:developer';

class HomeScreen extends StatefulWidget {
  final String? userId;
  
  const HomeScreen({
    this.userId,
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String? userName;
  bool isLoading = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ApiService apiService = new ApiService();
  bool _isExpanded = false;

  PageController _pageController = PageController();
  late YoutubePlayerController _controller;
  late PageController _pageViewController;
  late TabController _tabController;
  Map<String, dynamic>? profileData;
  int activeTabs = 1;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: 'RYMAkz8WUUI',
      flags: YoutubePlayerFlags(
        hideThumbnail: false,
        autoPlay: false,
        mute: false,
      ),
    );
    // Replace the below videoId with the actual YouTube video ID
    _videocontroller = YoutubePlayerController(
      initialVideoId: 'RYMAkz8WUUI',
      flags: YoutubePlayerFlags(
        hideThumbnail: false,
        autoPlay: false,
        mute: false,
      ),
    );
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      Provider.of<Userprovider>(context, listen: false).fetchProfileData();
    });
    getUserData();
    // _fetchProfileData();
    ApiService().testimonialsData();

  }

  Future<void> getUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Use null-aware operators when getting values
      String userId = prefs.getString("user_id") ?? '';
      String name = prefs.getString("name") ?? '';
      String email = prefs.getString("email") ?? '';
      // ... other fields

      // Update state only if data exists
      if (userId.isNotEmpty) {
        setState(() {
          userName = name;
          // ... other fields
        });
      }
    } catch (e) {
      log("Error getting user data: $e");
      // Handle error appropriately
    }
  }

  Future<void> _fetchProfileData() async {
    try {
      var result = await apiService.postProfileData();
      if (result['success']) {
        setState(() {
          profileData = result['data'];
        });
        print("name in home screen${profileData!["user"]["name"]}");
      } else {
        setState(() {
          // errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        // errorMessage = 'An unexpected error occurred: $e';
      });
    } finally {
      setState(() {
        isLoading = false; // Stop loading once the API call completes
      });
    }
  }

  late YoutubePlayerController _videocontroller;

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _closeDrawer() {
    _scaffoldKey.currentState?.closeDrawer();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    print(hour);

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  void clearPreferencesAndNavigate(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
      (Route<dynamic> route) => false, // This removes all previous routes
    );
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<Userprovider>(context);

    return WillPopScope(
      onWillPop: () async {
        // Exits the app when back button is pressed
        SystemNavigator.pop();
        return false; // Prevents further popping action
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                decoration:
                    BoxDecoration(border: Border(bottom: BorderSide.none)),
                height: MediaQuery.of(context).size.height * 0.4,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide.none),
                    image: DecorationImage(
                      image: AssetImage('assets/images/vector1.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: profileProvider.isLoading
                      ? SizedBox()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: _closeDrawer,
                                  child: Icon(
                                    Icons.arrow_back, // The back arrow icon (←)
                                    size: 30.0, // Adjust the size if needed
                                    color: Color(
                                        0xffffffff), // You can change the color
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Profile(index: "1")),
                                    );
                                  },
                                  child: Image.asset(
                                    "assets/images/pgd.png",
                                    width: 24,
                                  ),
                                ),
                              ],
                            ),
                            profileProvider.profileData!["user"]
                                        ["profile_image"] !=
                                    null
                                ? CircleAvatar(
                                    radius: 50.0,
                                    backgroundImage: (profileProvider
                                                    .profileData!['user']
                                                ['profile_image'] !=
                                            "")
                                        ? NetworkImage(
                                            profileProvider.profileData!['user']
                                                ['profile_image'])
                                        : AssetImage("assets/images/act1.png"))
                                : CircleAvatar(
                                    radius: 50.0,
                                    backgroundImage:
                                        AssetImage("assets/images/act1.png")),
                            SizedBox(
                              width: 40,
                              height: 10,
                            ),
                            Text(
                              profileProvider.profileData!["user"]["name"] ??
                                  '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              ListTile(
                leading: Image(
                  image: AssetImage("assets/images/smb1.png"),
                  color: Color(0xffD45700),
                ),
                title: Text('Home'),
                onTap: () {
                  // Navigate to Home
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.monetization_on_outlined, color: Color(0xffD45700),),
                title: Text('Subscription'),
                onTap: () {
                  // Navigate to Home
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SubscriptionScreen()
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.event_available, color: Color(0xffD45700),),
                title: Text('Attended Events'),
                onTap: () {
                  // Navigate to Home
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Attendedevent(userId: profileProvider.profileData!['user']['id']
                        .toString(),

                    )),
                  );
                },
              ),
              ListTile(
                leading: Image(
                  image: AssetImage(
                    "assets/images/smb2.png",
                  ),
                  color: Color(0xffD45700),
                ),
                title: Text('Our Team'),
                onTap: () {
                  _closeDrawer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OurTeam()),
                  );

                  // Navigate to Settings
                },
              ),
              ListTile(
                  leading: Image(
                    image: AssetImage("assets/images/smb3.png"),
                    color: Color(0xffD45700),
                  ),
                  title: Text('Blog '),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Blog()),
                    );
                  }),
              ListTile(
                  leading: Image(
                    image: AssetImage("assets/images/smb4.png"),
                    color: Color(0xffD45700),
                  ),
                  title: Text('Contact Us'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContactUs()),
                    );
                  }),
              ListTile(
                  leading: Image(
                    image: AssetImage("assets/images/mdi1.png"),
                    color: Color(0xffD45700),
                  ),
                  title: Text('About Us'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutUs()),
                    );
                  }),
              ListTile(
                  leading: Icon(Icons.pentagon, color: Color(0xffD45700),),
                  title: Text('Feedback'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FeedbackPage()),
                    );
                  }),
              ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Color(0xffD45700),
                  ),
                  title: const Text('Logout'),
                  onTap: () async {
                    clearPreferencesAndNavigate(context);
                  }),
            ],
          ),
        ),
        body: profileProvider.isLoading
            ? const SizedBox()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 22, left: 5, bottom: 15, right: 22),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.menu),
                                      onPressed: () {
                                        _scaffoldKey.currentState?.openDrawer();
                                      },
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    profileProvider.isLoading
                                        ? SizedBox()
                                        : Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              RichText(
                                                  text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Hello, ',
                                                    style: GoogleFonts.gotu(
                                                      color: Colors.black,
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: profileProvider.profileData?["user"]?["name"]?.split(' ')[0] ?? '',
                                                    style: GoogleFonts.gotu(
                                                      color: Color(0xffD45700),
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                ],
                                              )),
                                              Text(
                                                _getGreeting(),
                                                textAlign: TextAlign.left,
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      // Container(
                                      //     child: Icon(
                                      //   CupertinoIcons.bell,
                                      //   size: 28,
                                      //   color: Color(0xff545454),
                                      // )),
                                      SizedBox(width: 16),
                                      // InkWell(
                                      //   onTap: _openDrawer,

                                      // ),

                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Profile(index: '1')),
                                          );
                                        },
                                        child: profileProvider.profileData!["user"]
                                                    ["profile_image"] !=
                                                null
                                            ? CircleAvatar(
                                                radius: 23.0,
                                                backgroundImage: (profileProvider
                                                                .profileData!['user']
                                                            ['profile_image'] !=
                                                        "")
                                                    ? NetworkImage(profileProvider
                                                            .profileData!['user']
                                                        ['profile_image'])
                                                    : AssetImage(
                                                        "assets/images/act1.png"))
                                            : CircleAvatar(
                                                radius: 25,
                                                backgroundImage: AssetImage(
                                                    "assets/images/act1.png")),
                                      )
                                    ],
                                  ),
                                )
                              ]),
                        ),

                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: ClipRRect(
                            // borderRadius: BorderRadius.only(
                            //     topLeft: Radius.circular(20),
                            //     topRight: Radius.circular(20)),
                            child: YoutubePlayer(
                              controller: _videocontroller,
                              showVideoProgressIndicator: true,
                              onReady: () {
                                _videocontroller.addListener(() {
                                  // Handle events
                                });
                              },
                            ),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(15.0),
                        //   child: TextFormField(
                        //     // controller: _controller,
                        //     decoration: InputDecoration(
                        //       isDense: true,
                        //       prefixIcon: Padding(
                        //         padding: const EdgeInsets.only(left: 8.0),
                        //         child: Align(
                        //           alignment: Alignment.centerLeft,
                        //           child: Icon(
                        //             Icons.search,
                        //             color: Color(0xffD45700),
                        //             size: 28,
                        //           ),
                        //         ),
                        //       ),

                        //       filled: true, // Enables background color
                        //       fillColor: Colors.white, // Background color
                        //       border: OutlineInputBorder(
                        //         borderRadius:
                        //             BorderRadius.circular(35), // Rounded corners
                        //         borderSide: const BorderSide(
                        //           color:
                        //               Color.fromARGB(255, 83, 81, 81), // Border color
                        //           width: 327, // Border width
                        //         ),
                        //       ),
                        //       enabledBorder: OutlineInputBorder(
                        //         borderRadius: BorderRadius.circular(35),
                        //         borderSide: const BorderSide(
                        //           color: Color.fromARGB(
                        //               255, 124, 122, 122), // Border color when enabled
                        //         ),
                        //       ),
                        //       focusedBorder: OutlineInputBorder(
                        //         borderRadius: BorderRadius.circular(35),
                        //         borderSide: const BorderSide(
                        //           color: Color.fromARGB(
                        //               255, 120, 117, 117), // Border color when focused
                        //         ),
                        //       ),
                        //       labelStyle: const TextStyle(
                        //           fontSize: 16), // Customize label text size
                        //     ),
                        //     validator: (value) {
                        //       if (value == null ||
                        //           value.isEmpty ||
                        //           value.length > 10 ||
                        //           value.length < 10) {
                        //         return 'Please enter some your mobile number';
                        //       }
                        //       return null;
                        //     },
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.all(10),
                        //   child: Text(
                        //     'Trending Now',
                        //     style: TextStyle(
                        //         fontSize: 18,
                        //         fontWeight: FontWeight.bold,
                        //         color: Color(0xff33272A)),
                        //   ),
                        // ),
                        // Container(
                        //   height: 120, // Set a fixed height for the ListView
                        // child: ListView.builder(
                        //   scrollDirection: Axis.horizontal,
                        //   itemCount: 4, // Total number of items in the slider
                        //   itemBuilder: (context, index) {
                        // return Container(
                        //   width: MediaQuery.of(context).size.width /
                        //       4.4, // Show 4 items at a time
                        //   margin: EdgeInsets.symmetric(horizontal: 4),
                        //   decoration: BoxDecoration(
                        //     color: Colors.blueAccent,
                        //     borderRadius: BorderRadius.circular(10),
                        //   ),
                        //   child: Center(child: Image.asset("assets/images/card1.png")),
                        // );
                        //   },
                        // ),
                        // child: Row(
                        //   children: [
                        //     Container(
                        //       width: MediaQuery.of(context).size.width /
                        //           4.4, // Show 4 items at a time
                        //       margin: EdgeInsets.symmetric(horizontal: 4),
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(10),
                        //       ),
                        //       child: Center(
                        //         child: Stack(children: [
                        //           Image.asset("assets/images/RC1.png"),
                        //           Padding(
                        //             padding: const EdgeInsets.only(top: 2, left: 15),
                        //             child: Text(
                        //               'Dummy\nText',
                        //               style: TextStyle(
                        //                   fontSize: 10,
                        //                   fontWeight: FontWeight.bold,
                        //                   color: Color(0xffffffff)),
                        //               textAlign: TextAlign.center,
                        //             ),
                        //           ),
                        //           Padding(
                        //             padding:
                        //                 const EdgeInsets.only(top: 28.0, left: 6),
                        //             child: Image.asset("assets/images/RC2.png"),
                        //           )
                        //         ]),
                        //       ),
                        //     ),
                        //     Container(
                        //       width: MediaQuery.of(context).size.width /
                        //           4.4, // Show 4 items at a time
                        //       margin: EdgeInsets.symmetric(horizontal: 4),
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(10),
                        //       ),
                        //       child: Center(
                        //           child: Stack(children: [
                        //         Image.asset("assets/images/Rg1.png"),
                        //         Padding(
                        //           padding: const EdgeInsets.only(top: 2, left: 15),
                        //           child: Text(
                        //             'Dummy\nText',
                        //             style: TextStyle(
                        //                 fontSize: 10,
                        //                 fontWeight: FontWeight.bold,
                        //                 color: Color(0xff000000)),
                        //             textAlign: TextAlign.center,
                        //           ),
                        //         ),
                        //         Padding(
                        //           padding: const EdgeInsets.only(top: 28.0, left: 6),
                        //           child: Image.asset("assets/images/Rg2.png"),
                        //         )
                        //       ])),
                        //     ),
                        //     Container(
                        //       width: MediaQuery.of(context).size.width /
                        //           4.4, // Show 4 items at a time
                        //       margin: EdgeInsets.symmetric(horizontal: 4),
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(10),
                        //       ),
                        //       child: Center(
                        //           child: Stack(children: [
                        //         Image.asset("assets/images/Rg1.png"),
                        //         Padding(
                        //           padding: const EdgeInsets.only(top: 2.0, left: 15),
                        //           child: Text(
                        //             'Dummy\nText',
                        //             style: TextStyle(
                        //                 fontSize: 10,
                        //                 fontWeight: FontWeight.bold,
                        //                 color: Color(0xff000000)),
                        //             textAlign: TextAlign.center,
                        //           ),
                        //         ),
                        //         Padding(
                        //           padding: const EdgeInsets.only(top: 28.0, left: 6),
                        //           child: Image.asset("assets/images/Rg3.png"),
                        //         )
                        //       ])),
                        //     ),
                        //     Container(
                        //       width: MediaQuery.of(context).size.width /
                        //           4.4, // Show 4 items at a time
                        //       margin: EdgeInsets.symmetric(horizontal: 4),
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(10),
                        //       ),
                        //       child: Center(
                        //           child: Stack(children: [
                        //         Image.asset("assets/images/Rg1.png"),
                        //         Padding(
                        //           padding: const EdgeInsets.only(top: 2, left: 15),
                        //           child: Text(
                        //             'Dummy\nText',
                        //             style: TextStyle(
                        //                 fontSize: 10,
                        //                 fontWeight: FontWeight.bold,
                        //                 color: Color(0xff000000)),
                        //             textAlign: TextAlign.center,
                        //           ),
                        //         ),
                        //         Padding(
                        //           padding: const EdgeInsets.only(top: 28.0, left: 6),
                        //           child: Image.asset("assets/images/Rg4.png"),
                        //         )
                        //       ])),
                        //     ),
                        //   ],
                        // ),
                        // ),
                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Categories',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // InkWell(
                              //   onTap: () {
                              //     Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //             builder: (context) => SeeAll()));
                              //   },
                              //   child: Container(
                              //     decoration: BoxDecoration(
                              //         borderRadius:
                              //             BorderRadius.all(Radius.circular(30)),
                              //         border: Border.all(
                              //             width: 2,
                              //             color: const Color.fromARGB(
                              //                 255, 221, 99, 37))),
                              //     child: Padding(
                              //       padding: const EdgeInsets.symmetric(
                              //           horizontal: 8, vertical: 0),
                              //       child: Text('See all'),
                              //     ),
                              //   ),
                              // ),
                              // Padding(padding: const EdgeInsets.only(top: 10, left: 10))
                            ],
                          ),
                        ),
                        // Expanded(child: Programtab()),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    activeTabs = 1;
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 5,
                                  decoration: BoxDecoration(
                                      color: activeTabs == 1
                                          ? Color(0xffD45700)
                                          : Color(0xffffffff),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      border: Border.all(
                                          width: 2,
                                          color: const Color.fromARGB(
                                              255, 221, 99, 37))),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      'Programs',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: activeTabs == 1
                                              ? Colors.white
                                              : Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    activeTabs = 2;
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 5,
                                  decoration: BoxDecoration(
                                      color: activeTabs == 2
                                          ? Color(0xffD45700)
                                          : Color(0xffffffff),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      border: Border.all(
                                          width: 2,
                                          color: const Color.fromARGB(
                                              255, 221, 99, 37))),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      'Events',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: activeTabs == 2
                                              ? Colors.white
                                              : Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    activeTabs = 3;
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 5,
                                  decoration: BoxDecoration(
                                      color: activeTabs == 3
                                          ? Color(0xffD45700)
                                          : Color(0xffffffff),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      border: Border.all(
                                          width: 2,
                                          color: const Color.fromARGB(
                                              255, 221, 99, 37))),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      'Studio',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: activeTabs == 3
                                              ? Colors.white
                                              : Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    activeTabs = 4;
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 5,
                                  decoration: BoxDecoration(
                                      color: activeTabs == 4
                                          ? Color(0xffD45700)
                                          : Color(0xffffffff),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      border: Border.all(
                                          width: 2,
                                          color: const Color.fromARGB(
                                              255, 221, 99, 37))),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      'Gallery',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: activeTabs == 4
                                              ? Colors.white
                                              : Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (activeTabs == 1) const Programtab(),
                    if (activeTabs == 2)  Events(userId: profileProvider.profileData!['user']['id']
                        .toString(),),
                    if (activeTabs == 3) const Studio(),
                    if (activeTabs == 4) Gallery(),
                    // if (activeTabs == 5) const Programtab(),
                    // if (activeTabs == 6)  Events(userId: profileProvider.profileData!['user']['id']
                    //     .toString(),),
                    // if (activeTabs == 7) const Studio(),
                    // if (activeTabs == 8) Gallery(),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }
}

class SwipeableCard extends StatefulWidget {
  @override
  _SwipeableCardState createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard> {
  final PageController _controller = PageController();
  List<TestimonialsData>? testimonials;

  @override
  void initState() {
    super.initState();
    fetchTestimonials();
  }

  void fetchTestimonials() async {
    final TestimonialsResponse? response = await ApiService().testimonialsData();
    if (response != null) {
      print("API Response: $response");
      if (response.data.isNotEmpty) {
        print("Fetched testimonials: ${response.data}");
        setState(() {
          testimonials = response.data;
        });
      } else {
        print("No testimonials data or data is empty.");
        setState(() {
          testimonials = [];
        });
      }
    } else {
      print("Failed to fetch testimonials.");
      setState(() {
        testimonials = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final testimonialsList = testimonials ?? [];
    print("Testimonials list: $testimonialsList"); // Check the list contents
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: testimonialsList.isEmpty
              ? Center(child: Text("No testimonials available"))
              : PageView.builder(
            controller: _controller,
            itemCount: testimonialsList.length,
            itemBuilder: (context, index) {
              final test = testimonialsList[index];
              return Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Center(
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Stack(
                            children: [
                              Image.asset(
                                "assets/images/preview1.png",
                                height: 500,
                              ),
                              Positioned.fill(
                                child: Center(
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.35, // Ensure a fixed height

                                    child: SingleChildScrollView(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Center(
                                        child: Text(
                                          test.detail ?? "No detail available",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w300,
                                            color: Color(0xff666666),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(right: 15, bottom: 15),
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        test.name ?? 'No name available',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Color(0xffD45700)),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 20),
          child: SmoothPageIndicator(
            controller: _controller,
            count: testimonialsList.length,
            effect: WormEffect(dotHeight: 8, dotWidth: 8, activeDotColor: Color(0xffD45700)),
          ),
        ),
      ],
    );
  }

}
