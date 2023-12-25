import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colors.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  List<Map<String, dynamic>> doctorInfo = [];
  String? savedLabCodeID;
  String? patientID;

  @override
  void initState() {
    super.initState();
    getSavedLabCodeID();
  }

  Future<void> getSavedLabCodeID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedLabCodeID = prefs.getString('labCodeID');

      print('saved code : $savedLabCodeID');

      FetchDoctors();
    });
  }

  Future<void> FetchDoctors() async {
    final url =
        'http://ban58.thyroreport.com/api/Doctor/GetDoctorbyLabcodeID?Labcodeid=$savedLabCodeID';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        doctorInfo = List<Map<String, dynamic>>.from(jsonResponse);
      });
      print('docttorinfo: $doctorInfo');
    } else {
      print('Error! Server responded with status: ${response.statusCode}');
      throw Exception(' error fetching info: ');
    }
  }

  // List<String> getImageUrls() {
  //   if (savedLabCodeID == null) {
  //     // Handle the case where savedLabCodeID is null (maybe show an error message or return an empty list)
  //     return [];
  //   }

  //   final String imgPath =
  //       'http://ban58files.thyroreport.com/$savedLabCodeID/UploadedFiles/OfferPackage';

  //   return doctorInfo
  //       .map<String>((dynamic image) {
  //         // Provide a default value if 'aarogyamPackageFileName' is null or not present
  //         String imageName = image['doctorphoto'];
  //         String imageUrl = '$imgPath/$imageName';
  //         return imageUrl;
  //       })
  //       .where((imageUrl) => imageUrl.isNotEmpty) // Remove empty URLs
  //       .toList();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctor',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AC.TC,
      ),
      body: ListView.builder(
          itemCount: doctorInfo.length,
          itemBuilder: (BuildContext context, int index) {
            final name = doctorInfo[index]['doctorName'] ?? '';
            final type = doctorInfo[index]['doctorType'] ?? '';
            final edu = doctorInfo[index]['doctorEdu'] ?? '';
            final exp = doctorInfo[index]['doctorExp'] ?? '';
            final photo = doctorInfo[index]['doctorphoto'] ?? '';
            final desc = doctorInfo[index]['doctorDesc'] ?? '';
            final cost = doctorInfo[index]['cost'].toString() ?? '';
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 170,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    gradient: AC.grBG,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 15,
                          offset: Offset(0, 0.8))
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        'http://ban58files.thyroreport.com/$savedLabCodeID/UploadedFiles/DrImage/$photo'),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35))),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$name  ($edu)',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              Text(
                                type,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                exp,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          desc,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '₹ $cost Consultation Fees',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            // shadows: [
                            //   Shadow(
                            //       offset: Offset(0, 2),
                            //       blurRadius: 15,
                            //       color: Colors.white.withOpacity(0.5))
                            // ]
                          ),
                        ),
                      )
                    ]),
              ),
            );
          }),
    );
  }
}
