import 'package:flutter/material.dart';

class SeeAll extends StatefulWidget {
  const SeeAll({super.key});

  @override
  State<SeeAll> createState() => _SeeAllState();
}

PageController _pageController = PageController();
// late YoutubePlayerController _controller;
late PageController _pageViewController;
late TabController _tabController;
int activeTabs = 1;

class _SeeAllState extends State<SeeAll> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Categories',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
      ),
      body: Column(
        children: [
          // Container(
          //   margin: EdgeInsets.only(top: 50, right: 220),
          //   child: Text(
          //     'Categories',
          //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          //   ),
          // ),
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
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(255, 221, 99, 37))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Programs',
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                activeTabs == 1 ? Colors.white : Colors.black),
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
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(255, 221, 99, 37))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Events',
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                activeTabs == 2 ? Colors.white : Colors.black),
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
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(255, 221, 99, 37))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Studio',
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                activeTabs == 3 ? Colors.white : Colors.black),
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
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(255, 221, 99, 37))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Gallery',
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                activeTabs == 4 ? Colors.white : Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      activeTabs = 5;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 5,
                    decoration: BoxDecoration(
                        color: activeTabs == 5
                            ? Color(0xffD45700)
                            : Color(0xffffffff),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(255, 221, 99, 37))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Programs',
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                activeTabs == 1 ? Colors.white : Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      activeTabs = 6;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 5,
                    decoration: BoxDecoration(
                        color: activeTabs == 6
                            ? Color(0xffD45700)
                            : Color(0xffffffff),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(255, 221, 99, 37))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Events',
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                activeTabs == 2 ? Colors.white : Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      activeTabs = 7;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 5,
                    decoration: BoxDecoration(
                        color: activeTabs == 7
                            ? Color(0xffD45700)
                            : Color(0xffffffff),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(255, 221, 99, 37))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Studio',
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                activeTabs == 3 ? Colors.white : Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      activeTabs = 8;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 5,
                    decoration: BoxDecoration(
                        color: activeTabs == 8
                            ? Color(0xffD45700)
                            : Color(0xffffffff),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(255, 221, 99, 37))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Gallery',
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                activeTabs == 8 ? Colors.white : Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //      if (activeTabs == 1) const Programtab(),
          // if (activeTabs == 2) const Events(),
          // if (activeTabs == 3) const Studio(),
          // if (activeTabs == 4) Gallery(),
        ],
      ),
    ));
  }
}
