import 'package:divine_soul_yoga/src/api_service/apiservice.dart';
import 'package:divine_soul_yoga/src/models/testimonialsmodel.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/about_us.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/attended_event.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/blog.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/contact_us.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/events.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/feedback_screen.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/gallery.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/our_team.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/profile.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/program_tab.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/studio.dart';
import 'package:divine_soul_yoga/src/presentation/home_screen/subscription.dart';
import 'package:divine_soul_yoga/src/presentation/login/login.dart';
import 'package:divine_soul_yoga/src/presentation/utils/logout_dialog.dart';
import 'package:divine_soul_yoga/src/provider/userprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:developer';

class HomeScreen extends StatefulWidget {
  final String? userId;

  const HomeScreen({
    this.userId,
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String? userName;
  bool isLoading = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ApiService apiService = ApiService();

  final PageController _pageController = PageController();
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
      flags: const YoutubePlayerFlags(
        hideThumbnail: false,
        autoPlay: false,
        mute: false,
      ),
    );
    // Replace the below videoId with the actual YouTube video ID
    _videocontroller = YoutubePlayerController(
      initialVideoId: 'RYMAkz8WUUI',
      flags: const YoutubePlayerFlags(
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
                                  child: const Icon(
                                    Icons.arrow_back,
                                    size: 30.0,
                                    color: Color(0xffffffff),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const Profile(index: "1"),
                                      ),
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
                                        : const AssetImage(
                                            "assets/images/act1.png"))
                                : const CircleAvatar(
                                    radius: 50.0,
                                    backgroundImage:
                                        AssetImage("assets/images/act1.png")),
                            const SizedBox(
                              width: 40,
                              height: 10,
                            ),
                            Text(
                              profileProvider.profileData!["user"]["name"] ??
                                  '',
                              style: const TextStyle(
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
                leading: const Image(
                  image: AssetImage("assets/images/smb1.png"),
                  color: Color(0xffD45700),
                ),
                title: const Text('Home'),
                onTap: () {
                  // Navigate to Home
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.monetization_on_outlined,
                  color: Color(0xffD45700),
                ),
                title: const Text('Subscription'),
                onTap: () {
                  // Navigate to Home
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.event_available,
                  color: Color(0xffD45700),
                ),
                title: const Text('Attended Events'),
                onTap: () {
                  // Navigate to Home
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Attendedevent(
                              userId: profileProvider.profileData!['user']['id']
                                  .toString(),
                            )),
                  );
                },
              ),
              ListTile(
                leading: const Image(
                  image: AssetImage(
                    "assets/images/smb2.png",
                  ),
                  color: Color(0xffD45700),
                ),
                title: const Text('Our Team'),
                onTap: () {
                  _closeDrawer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OurTeam()),
                  );

                  // Navigate to Settings
                },
              ),
              ListTile(
                  leading: const Image(
                    image: AssetImage("assets/images/smb3.png"),
                    color: Color(0xffD45700),
                  ),
                  title: const Text('Blog '),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Blog()),
                    );
                  }),
              ListTile(
                  leading: const Image(
                    image: const AssetImage("assets/images/smb4.png"),
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
                  leading: Icon(
                    Icons.pentagon,
                    color: Color(0xffD45700),
                  ),
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
                onTap: () {
                  Navigator.pop(context);
                  LogoutDialog.show(context);
                },
              ),
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
                          padding: const EdgeInsets.only(
                              top: 22, left: 5, bottom: 15, right: 22),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.menu),
                                      onPressed: () {
                                        _scaffoldKey.currentState?.openDrawer();
                                      },
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    profileProvider.isLoading
                                        ? const SizedBox()
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              RichText(
                                                  text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Hello, ',
                                                    style: GoogleFonts.gotu(
                                                      color: Colors.black,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: profileProvider
                                                            .profileData?[
                                                                "user"]?["name"]
                                                            ?.split(' ')[0] ??
                                                        '',
                                                    style: GoogleFonts.gotu(
                                                      color: Color(0xffD45700),
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                ],
                                              )),
                                              Text(
                                                _getGreeting(),
                                                textAlign: TextAlign.left,
                                                style: GoogleFonts.gotu(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 16),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Profile(index: '1')),
                                          );
                                        },
                                        child: profileProvider
                                                        .profileData!["user"]
                                                    ["profile_image"] !=
                                                null
                                            ? CircleAvatar(
                                                radius: 23.0,
                                                backgroundImage: (profileProvider
                                                                    .profileData![
                                                                'user']
                                                            ['profile_image'] !=
                                                        "")
                                                    ? NetworkImage(profileProvider
                                                                .profileData![
                                                            'user']
                                                        ['profile_image'])
                                                    : const AssetImage(
                                                        "assets/images/act1.png"),
                                              )
                                            : const CircleAvatar(
                                                radius: 25,
                                                backgroundImage: AssetImage(
                                                    "assets/images/act1.png"),
                                              ),
                                      )
                                    ],
                                  ),
                                )
                              ]),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: ClipRRect(
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
                        const SizedBox(
                          height: 20,
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Categories',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
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
                                          ? const Color(0xffD45700)
                                          : const Color(0xffffffff),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(30)),
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
                                          ? const Color(0xffD45700)
                                          : const Color(0xffffffff),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(30)),
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
                                          ? const Color(0xffD45700)
                                          : const Color(0xffffffff),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(30)),
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
                                          ? const Color(0xffD45700)
                                          : const Color(0xffffffff),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(30)),
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
                    if (activeTabs == 2)
                      Events(
                        userId: profileProvider.profileData!['user']['id']
                            .toString(),
                      ),
                    if (activeTabs == 3) const Studio(),
                    if (activeTabs == 4) const Gallery(),
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
    final TestimonialsResponse? response =
        await ApiService().testimonialsData();
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
              ? const Center(child: Text("No testimonials available"))
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      "assets/images/preview1.png",
                                      height: 500,
                                    ),
                                    Positioned.fill(
                                      child: Center(
                                        child: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.35,
                                          child: Center(
                                            child: Text(
                                              test.detail ??
                                                  "No detail available",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w300,
                                                color: const Color(0xff666666),
                                              ),
                                              textAlign: TextAlign.center,
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
            effect: WormEffect(
                dotHeight: 8, dotWidth: 8, activeDotColor: Color(0xffD45700)),
          ),
        ),
      ],
    );
  }
}
