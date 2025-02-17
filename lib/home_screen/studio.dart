import 'package:divine_soul_yoga/api_service/apiservice.dart';
import 'package:divine_soul_yoga/home_screen/studio_detail.dart';
import 'package:divine_soul_yoga/models/eventmodel.dart';
import 'package:divine_soul_yoga/utils/googlemaps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../models/studio_model.dart';

class Studio extends StatefulWidget {
  const Studio({super.key});

  @override
  State<Studio> createState() => _StudioState();
}

class _StudioState extends State<Studio> {
  bool isLoading = false;
  List<StudioData>? studioData;
  //InAppWebViewController _webViewController;
  String url = "";
  double progress = 0;

  @override
  void initState() {
    super.initState();
    getStudioData();
  }

  Future<void> getStudioData() async {
    setState(() {
      isLoading = true; // Show loading indicator while fetching data
    });

    try {
      studioData = await ApiService().fetchStudioData(); // Fetch the data
    } catch (e) {
      print('Error fetching studio data: $e'); // Handle errors
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return isLoading
        ? Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : SingleChildScrollView(
            // Wrap the whole content in SingleChildScrollView
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 10, 0, 10),
                  child: Text(
                    "Top headlines",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color.fromRGBO(253, 96, 5, 1),
                    ),
                  ),
                ),
                // Remove SingleChildScrollView around ListView, ListView can handle scroll
                ListView.builder(
                  itemCount: studioData!.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.025,
                  ),
                  itemBuilder: (context, index) {
                    final data = studioData?[index];
                    return GestureDetector(
                      onTap: () {
                        print("IFrame: ${data.location}");
                        startNavigation(data.address);
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => StudioDetails(studioData: studioData![index],)));
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width * 0.025,
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
    //                           Container(
    //                               height:
    //                                   MediaQuery.of(context).size.height * 0.2,
    //                               decoration: BoxDecoration(
    //                                 //color: Colors.grey,
    //                                 borderRadius: BorderRadius.circular(
    //                                   MediaQuery.of(context).size.width * 0.025,
    //                                 ),
    //                               ),
    //                               child: InAppWebView(
    //                                 initialData: InAppWebViewInitialData(
    //                                   data: """
    //   <!DOCTYPE html>
    //   <html lang="en">
    //   <head>
    //     <meta charset="UTF-8">
    //     <meta name="viewport" content="width=device-width, initial-scale=1.0">
    //     <title>Google Map</title>
    //     <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDaO-jjmk06YaFSmT3d2YvvxD_fQYIfv3w"></script>
    //   </head>
    //   <body>
    //     ${data!.location}
    //   </body>
    //   </html>
    // """,
    //                                 ),
    //                                 // initialUrlRequest: URLRequest(
    //                                 //     url: WebUri(
    //                                 //         "https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d14016.67646359021!2d77.158436!3d28.564684000000003!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x390d1daf73bc3b35%3A0xc83fb9f3d589e756!2sBlock%20E%2C%20Vasant%20Vihar%2C%20New%20Delhi%2C%20Delhi%20110057%2C%20India!5e0!3m2!1sen!2sus!4v1734422471848!5m2!1sen!2sus")),
    //                                 onLoadStart: (controller, url) {
    //                                   print("Started loading: $url");
    //                                   CircularProgressIndicator();
    //                                 },
    //                                 onLoadStop: (controller, url) async {
    //                                   print("Finished loading: $url");
    //                                 },
    //                                 onProgressChanged: (controller, progress) {
    //                                   print("Loading progress: $progress%");
    //                                 },
    //                               )
    //                           ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 25, horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                      Text(
                                        data!.title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Color.fromRGBO(253, 96, 5, 1),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: (){
                                          startNavigation(data.address);
                                        },
                                          child:
                                          //Icon(Icons.directions, size: 35,),
                                          Text('Get Direction', style: TextStyle(fontWeight: FontWeight.bold),)
                                      )
                                    ],),


                                    SizedBox(height: 10),
                                    Text(data.address),
                                    SizedBox(height: 20),
                                    Text(
                                      "Contact Details",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text("Email: ${data.details}"),
                                    Text("Phone: ${data.contactNumber}"),
                                    SizedBox(height: 20),
                                    Text(
                                      "Open Hours",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text("Tue - Sun: 9:00 AM - 7:00 PM IST"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
  }
}
