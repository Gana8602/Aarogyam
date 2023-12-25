import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:thyrocare/utils/colors.dart';

class MedicalStoresPage extends StatefulWidget {
  @override
  _MedicalStoresPageState createState() => _MedicalStoresPageState();
}

class _MedicalStoresPageState extends State<MedicalStoresPage> {
  List<dynamic> storesData = [];
  String? savedLabCodeID;

  @override
  void initState() {
    super.initState();
    getSavedLabCodeID();
  }

  Future<void> getSavedLabCodeID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedLabCodeID = prefs.getString('labCodeID');
      fetchStoresData();
    });
  }

  Future<void> fetchStoresData() async {
    final response = await http.get(Uri.parse(
        'http://ban58.thyroreport.com/api/MedStore/GetAllMedStorebyLabcodeid?Labcodeid=$savedLabCodeID'));

    if (response.statusCode == 200) {
      setState(() {
        storesData = json.decode(response.body);
      });
    } else {
      print('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AC.TC,
        title: const Text(
          'Medical Stores',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: storesData.length,
        itemBuilder: (context, index) {
          final store = storesData[index];
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Light grey shadow
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(
                          0, 4), // Changes the position of the shadow
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(15))),
              height: 250,
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "Store: ${store['medStoreName']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            const Text(
                              'Phone:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(' ${store['phoneNo']}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Text(
                          'Owner:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(' ${store['ownerName']}'),
                      ],
                    ),
                  ),
                  Container(
                    height: 180,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                'http://ban58files.thyroreport.com/$savedLabCodeID/UploadedFiles/OfferPackage/${store['medStoreFilename']}'),
                            fit: BoxFit.cover)),
                  ),
                ],
              ),

              // child: ListTile(
              //   title: Text(store['medStoreName']),
              //   subtitle: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text('Owner: ${store['ownerName']}'),
              //       Text('Phone: ${store['phoneNo']}'),
              //     ],
              //   ),
              //   leading: GestureDetector(
              //       onTap: () {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => LargerImageView(
              //                     imageUrl: store['medStoreFilename'])));
              //       },
              //       child: Container(
              //         height: 100,
              //         width: 100,
              //         decoration: BoxDecoration(
              //             image: DecorationImage(
              //                 image: NetworkImage(
              //                     'http://ban58files.thyroreport.com/UploadedFiles/OfferPackage/${store['medStoreFilename']}'),
              //                 fit: BoxFit.cover)),
              //       )),
              // ),
            ),
          );
        },
      ),
    );
  }
}
