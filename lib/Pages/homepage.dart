// import 'dart:async';
// import 'dart:convert';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:lecle_flutter_carousel_pro/lecle_flutter_carousel_pro.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:thyrocare/Pages/Monthly_offer.dart';
// import 'package:thyrocare/Pages/mainpage.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher_string.dart';
// import 'package:whatsapp_unilink/whatsapp_unilink.dart';
// import 'package:http/http.dart' as http;

// class homePage extends StatefulWidget {
//   final GlobalKey<CurvedNavigationBarState> navigationKey;
//   const homePage({
//     super.key,
//     required this.navigationKey,
//   });

//   @override
//   State<homePage> createState() => _homePageState();
// }

// class _homePageState extends State<homePage> {
//   String? patientID;
//   List<Map<String, dynamic>> testData = [];
//   @override
//   void initState() {
//     super.initState();
//     GetIamges(); // Call the method to fetch images when the widget initializes
//     retrieveUserData();
//     retrieveCashbackData();
//     fetchAndSetTestData();
//   }

//   Future<List<Map<String, dynamic>>> fetchTestData() async {
//     final response = await http.get(
//         Uri.parse('http://ban58.thyroreport.com/api/LabTest/GetActiveTest'));

//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       return List<Map<String, dynamic>>.from(data);
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }

//   Future<void> fetchAndSetTestData() async {
//     try {
//       List<Map<String, dynamic>> data = await fetchTestData();
//       setState(() {
//         testData = data;
//       });
//     } catch (e) {
//       print('Error: $e');
//       // Handle error or show a message to the user
//     }
//   }

//   Future<void> GetLocalTest() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       // Retrieve data from SharedPreferences
//       patientID = prefs.getString('patientID');
//       print('patientid = $patientID');
//     });
//   }

//   Future<List<Map<String, dynamic>>> fetchData() async {
//     final response = await http.get(Uri.parse(
//         'http://ban58.thyroreport.com/api/Cashback/GetCashbackByPatientID?PatientID=$patientID'));

//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       print(response.body);
//       List<Map<String, dynamic>> availableResponses = data
//           .where((item) => item['isExpired'].trim() == "Available")
//           .toList()
//           .cast<
//               Map<String,
//                   dynamic>>(); // Ensure data is cast to Map<String, dynamic>
//       return availableResponses; // Return the filtered data
//     } else {
//       print('Request failed with status: ${response.statusCode}');
//       print('Response: ${response.body}');
//       throw Exception('Failed to load cashback data');
//     }
//   }

//   Future<void> retrieveCashbackData() async {
//     try {
//       if (patientID != null) {
//         List<Map<String, dynamic>> data = await fetchData();
//         setState(() {
//           availableResponses = data;
//         });
//       }
//     } catch (e) {
//       print('Error: $e');
//       // Handle error or show a message to the user
//     }
//   }

//   Future<void> retrieveUserData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       patientID = prefs.getString('patientID');
//       print('patientID = $patientID');
//       if (patientID != null) {
//         retrieveCashbackData(); // If patientID is retrieved, get the cashback data
//       }
//     });
//   }

//   final String imgPath =
//       'http://ban58files.thyroreport.com/UploadedFiles/OfferPackage/';
//   Future<void> GetIamges() async {
//     final url = 'http://ban58.thyroreport.com/api/Package/GetAllPackage';

//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       List jsonData = json.decode(response.body);
//       print(response.body);
//       if (jsonData.isNotEmpty) {
//         setState(() {
//           Imagess = jsonData;
//         });
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         prefs.setString('userData', json.encode(jsonData));
//       }
//     } else {
//       print('Request failed with status: ${response.statusCode}');
//     }
//   }

//   List<String> getImageUrls() {
//     return Imagess.map<String>((dynamic image) {
//       String imageName = image[
//           'packageFileName']; // Use the key you receive in the API response
//       String imageUrl = imgPath + imageName;
//       return imageUrl;
//     }).toList();
//   }

//   List<Map<String, dynamic>> availableResponses = [];
//   List<Map<String, dynamic>> cashbackData = [];
//   List<dynamic> Imagess = [];
//   final List<IconData> icons1 = [
//     // Icons.home,
//     Icons.book_sharp,
//     Icons.wallet,
//     CupertinoIcons.rays,
//     Bootstrap.toggle_off,
//   ];
//   final List<IconData> icons2 = [
//     Iconsax.whatsapp,
//     Icons.contact_phone_outlined,
//   ];
//   @override
//   Widget build(BuildContext context) {
//     List<String> imageUrls = getImageUrls();
//     return Scaffold(
//       body: ListView(
//         children: [
//           Container(
//             height: 350,
//             decoration: const BoxDecoration(
//                 image: DecorationImage(
//               image: AssetImage('assets/wave.png'),
//               fit: BoxFit.cover,
//             )),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.all(15.0),
//                   child: Text(
//                     'Available Cashhback',
//                     style: TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white),
//                   ),
//                 ),
//                 availableResponses.isNotEmpty
//                     ? Padding(
//                         padding:
//                             const EdgeInsets.only(left: 15.0, bottom: 10.0),
//                         child: Text(
//                           '₹ ${availableResponses.first['cashbackAmt']}', // Adjust this line
//                           style: const TextStyle(
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white60),
//                         ),
//                       )
//                     : const Padding(
//                         padding: EdgeInsets.only(left: 15.0),
//                         child: Text(
//                           'Please Login to get cashback',
//                           style: TextStyle(
//                               fontSize: 17,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white60),
//                         ),
//                       ),
//                 const SizedBox(
//                   height: 10.0,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//                   child: CarouselSlider(
//                     options: CarouselOptions(
//                       aspectRatio: 16 / 8,
//                       viewportFraction: 0.8,
//                       enableInfiniteScroll: true,
//                       autoPlay: true,
//                     ),
//                     items: imageUrls.map((dynamic imageUrl) {
//                       return Builder(
//                         builder: (BuildContext context) {
//                           return Container(
//                             height: 100,
//                             width: MediaQuery.of(context).size.width,
//                             margin:
//                                 const EdgeInsets.symmetric(horizontal: 10.0),
//                             decoration: BoxDecoration(
//                                 color: Colors.grey,
//                                 borderRadius: const BorderRadius.all(
//                                   Radius.circular(20),
//                                 ),
//                                 image: DecorationImage(
//                                     image: NetworkImage(
//                                       imageUrl,
//                                     ),
//                                     fit: BoxFit.fill)),
//                             // child: Image.asset(
//                             //   image,
//                             //   fit: BoxFit.cover,
//                             // ),
//                           );
//                         },
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(
//             height: 10,
//           ),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: 4,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 2.3, // Adjust this as needed
//             ),
//             itemBuilder: (BuildContext context, int index) {
//               return GridItemWidget(
//                 index: index + 0,
//                 iconData: icons1[index],
//                 navigationKey: widget.navigationKey,
//               );
//             },
//           ),
//           Container(
//             height: 60,
//             width: MediaQuery.of(context).size.width,
//             decoration: const BoxDecoration(
//                 // boxShadow: [
//                 //   BoxShadow(
//                 //     color: Colors.grey.withOpacity(0.5), // Light grey shadow
//                 //     spreadRadius: 2,
//                 //     blurRadius: 4,
//                 //     offset: const Offset(
//                 //         0, 4), // Changes the position of the shadow
//                 //   ),
//                 // ],
//                 color: Colors.white,
//                 borderRadius: BorderRadius.all(Radius.circular(10))),
//             child: const Padding(
//               padding: EdgeInsets.all(15.0),
//               child: Text(
//                 'Contact Us',
//                 style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: 2,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 2.2, // Adjust this as needed
//             ),
//             itemBuilder: (BuildContext context, int index) {
//               return GridItemWidget2(
//                 index: index + 0,
//                 iconData: icons2[index],
//               );
//             },
//           ),
//           const SizedBox(
//             height: 15,
//           ),
//           Container(
//             height: 60,
//             width: MediaQuery.of(context).size.width,
//             decoration: const BoxDecoration(
//                 // boxShadow: [
//                 //   BoxShadow(
//                 //     color: Colors.grey.withOpacity(0.5), // Light grey shadow
//                 //     spreadRadius: 2,
//                 //     blurRadius: 4,
//                 //     offset: const Offset(
//                 //         0, 4), // Changes the position of the shadow
//                 //   ),
//                 // ],
//                 color: Colors.white,
//                 borderRadius: BorderRadius.all(Radius.circular(10))),
//             child: const Padding(
//               padding: EdgeInsets.all(15.0),
//               child: Text(
//                 'Monthly Offers',
//                 style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           Container(
//               height: 220,
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 scrollDirection:
//                     Axis.horizontal, // Ensure it scrolls horizontally
//                 itemCount: imageUrls.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   return Padding(
//                     padding: const EdgeInsets.only(left: 8.0, right: 8.0),
//                     child: Container(
//                       height: 200,
//                       width: 180,
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           image: NetworkImage(imageUrls[index]),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               )),
//           const SizedBox(
//             height: 15,
//           ),
//           Container(
//             height: 60,
//             width: MediaQuery.of(context).size.width,
//             decoration: const BoxDecoration(
//                 // boxShadow: [
//                 //   BoxShadow(
//                 //     color: Colors.grey.withOpacity(0.5), // Light grey shadow
//                 //     spreadRadius: 2,
//                 //     blurRadius: 4,
//                 //     offset: const Offset(
//                 //         0, 4), // Changes the position of the shadow
//                 //   ),
//                 // ],
//                 color: Colors.white,
//                 borderRadius: BorderRadius.all(Radius.circular(10))),
//             child: const Padding(
//               padding: EdgeInsets.all(15.0),
//               child: Text(
//                 'Test Rate',
//                 style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),

//           const SizedBox(
//             height: 10,
//           ),

//           Container(
//             child: Container(
//                 height: 80,
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   scrollDirection:
//                       Axis.horizontal, // Ensure it scrolls horizontally
//                   itemCount: testData.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     return Padding(
//                       padding: const EdgeInsets.only(
//                           left: 8.0, right: 8.0, bottom: 8.0),
//                       child: Container(
//                         height: 50,
//                         width: 180,
//                         decoration: BoxDecoration(
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey
//                                   .withOpacity(0.2), // Light grey shadow
//                               spreadRadius: 2,
//                               blurRadius: 4,
//                               offset: const Offset(
//                                   0, 4), // Changes the position of the shadow
//                             ),
//                           ],
//                           borderRadius:
//                               const BorderRadius.all(Radius.circular(15)),
//                           color: Colors.white,
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Text(
//                               testData[index]['testName'],
//                               style: const TextStyle(
//                                   fontSize: 14, fontWeight: FontWeight.bold),
//                             ),
//                             Text(
//                               testData[index]['cost'].toString(),
//                               style: const TextStyle(
//                                   fontSize: 14, fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 )),
//           ),
//           const SizedBox(
//             height: 20,
//           ),

//           // Row(
//           //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           //   children: [
//           //     for (int i = 0; i < 3; i++)
//           //       Container(
//           //         height: 60,
//           //         width: 80,
//           //         color: Colors.red,
//           //       )
//           //   ],
//           // )
//         ],
//       ),
//     );
//   }
// }

// class GridItemWidget extends StatelessWidget {
//   final int index;
//   final IconData iconData;
//   final GlobalKey<CurvedNavigationBarState> navigationKey;
//   const GridItemWidget({
//     required this.index,
//     required this.navigationKey,
//     required this.iconData,
//   });

//   void _makePhoneCall(String phoneNumber) async {
//     if (await launchUrlString('tel:$phoneNumber')) {
//       await launch('tel:$phoneNumber');
//     } else {
//       throw 'Could not launch $phoneNumber';
//     }
//   }

//   launchWhatsAppString() async {
//     const link = WhatsAppUnilink(
//       phoneNumber: '+91 8248596881',
//       text: "Hey! I'm inquiring about the apartment listing",
//     );
//     // Convert the WhatsAppUnilink instance to a string.
//     // Use either Dart's string interpolation or the toString() method.
//     // The "launchUrlString" method is part of "url_launcher_string".
//     await launchUrlString('$link');
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<String> Title = [
//       'My Reports',
//       'Cashback',
//       'Offers',
//       'Monthly Offers',
//     ];

//     return Center(
//       child: GestureDetector(
//         onTap: () {
//           // Example navigation logic based on the index
//           switch (index) {
//             case 0:
//               // Navigate to My Reports
//               // Example using GetX
//               // Navigator.pushReplacement(
//               //   context,
//               //   MaterialPageRoute(
//               //       builder: (context) => Home(
//               //             name: '',
//               //             onNavigation: (int value) {
//               //               // Perform operations based on the 'value' received
//               //               print('Received value: $value');
//               //               // ... Other operations based on this value
//               //             },
//               //             // myCurrentIndex: 0,
//               //           )),
//               // );
//               final navigationState = navigationKey.currentState!;
//               navigationState.setPage(1);
//               // or Navigator.push for Flutter
//               // Navigator.push(context, MaterialPageRoute(builder: (context) => MyReportsPage()));
//               break;
//             case 1:
//               // Navigate to Cashback
//               // Example using GetX
//               final navigationState = navigationKey.currentState!;
//               navigationState.setPage(2);
//               // or Navigator.push for Flutter
//               // Navigator.push(context, MaterialPageRoute(builder: (context) => CashbackPage()));
//               break;
//             case 2:
//               // Navigate to Cashback
//               // Example using GetX
//               final navigationState = navigationKey.currentState!;
//               navigationState.setPage(3);
//               // or Navigator.push for Flutter
//               // Navigator.push(context, MaterialPageRoute(builder: (context) => CashbackPage()));
//               break;
//             case 3:
//               // Navigate to Cashback
//               // Example using GetX
//               Get.to(const MonthlyOffer());
//               // or Navigator.push for Flutter
//               // Navigator.push(context, MaterialPageRoute(builder: (context) => CashbackPage()));
//               break;

//             // Add cases for other items as needed
//             default:
//               break;
//           }
//         },
//         child: Container(
//           height: 60,
//           width: 180,
//           decoration: BoxDecoration(
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.5), // Light grey shadow
//                 spreadRadius: 2,
//                 blurRadius: 4,
//                 offset:
//                     const Offset(0, 4), // Changes the position of the shadow
//               ),
//             ],
//             borderRadius: const BorderRadius.all(Radius.circular(15)),
//             color: Colors.white,
//           ),
//           // margin: EdgeInsets.all(5),
//           // Container background color
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Icon(
//                 iconData, // Replace with your desired icon
//                 size: 30,
//                 color: Colors.blueAccent,
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 Title[index], // Replace with your desired title
//                 style: const TextStyle(
//                   color: Colors.blue,
//                   fontSize: 15,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class GridItemWidget2 extends StatelessWidget {
//   final int index;
//   final IconData iconData;
//   const GridItemWidget2({required this.index, required this.iconData});

//   makePhoneCall(String phoneNumber) async {
//     if (await launchUrlString('tel:$phoneNumber')) {
//       await launch('tel:$phoneNumber');
//     } else {
//       throw 'Could not launch $phoneNumber';
//     }
//   }

//   launchWhatsAppString() async {
//     const link = WhatsAppUnilink(
//       phoneNumber: '+91 9739100747',
//       text: "Hey! I'm inquiring about the apartment listing",
//     );
//     // Convert the WhatsAppUnilink instance to a string.
//     // Use either Dart's string interpolation or the toString() method.
//     // The "launchUrlString" method is part of "url_launcher_string".
//     await launchUrlString('$link');
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<String> Title = [
//       'Whatsapp',
//       'Call Us',
//     ];

//     return Center(
//       child: GestureDetector(
//         onTap: () {
//           // Example navigation logic based on the index
//           switch (index) {
//             case 0:
//               // Navigate to My Reports
//               // Example using GetX
//               Get.to(launchWhatsAppString());
//               // or Navigator.push for Flutter
//               // Navigator.push(context, MaterialPageRoute(builder: (context) => MyReportsPage()));
//               break;
//             case 1:
//               // Navigate to Cashback
//               // Example using GetX
//               Get.to(makePhoneCall('9739100747'));
//               // or Navigator.push for Flutter
//               // Navigator.push(context, MaterialPageRoute(builder: (context) => CashbackPage()));
//               break;
//             // Navigate to Cashback

//             // Add cases for other items as needed
//             default:
//               break;
//           }
//         },
//         child: Container(
//           height: 60,
//           width: 180,
//           decoration: BoxDecoration(
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.5), // Light grey shadow
//                 spreadRadius: 2,
//                 blurRadius: 4,
//                 offset:
//                     const Offset(0, 4), // Changes the position of the shadow
//               ),
//             ],
//             borderRadius: const BorderRadius.all(Radius.circular(15)),
//             color: Colors.white,
//           ),
//           // margin: EdgeInsets.all(5),
//           // Container background color
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Icon(
//                 iconData, // Replace with your desired icon
//                 size: 30,
//                 color: Colors.blueAccent,
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 Title[index], // Replace with your desired title
//                 style: const TextStyle(
//                   color: Colors.blue,
//                   fontSize: 15,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
