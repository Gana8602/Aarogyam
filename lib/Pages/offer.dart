import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/colors.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class Offers extends StatefulWidget {
  const Offers({super.key});

  @override
  State<Offers> createState() => _OffersState();
}

class _OffersState extends State<Offers> {
  String? savedLabCodeID;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSavedLabCodeID();
  }

  Future<void> getSavedLabCodeID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedLabCodeID = prefs.getString('labCodeID');
      GetIamges();
    });
  }

  Future<void> GetIamges() async {
    final url = 'http://ban58.thyroreport.com/api/Offer/GetAllOffer';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      print(response.body);
      if (jsonData.isNotEmpty) {
        setState(() {
          Imagess = jsonData;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userData', json.encode(jsonData));
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  List<String> getImageUrls() {
    final String imgPath =
        'http://ban58files.thyroreport.com/$savedLabCodeID/UploadedFiles/OfferPackage/';
    return Imagess.map<String>((dynamic image) {
      String imageName =
          image['offerFileName']; // Use the key you receive in the API response
      String imageUrl = imgPath + imageName;
      return imageUrl;
    }).toList();
  }

  Future<void> ShowDialogBox(String image) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Zoom to View',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          content: Container(
            height: 250,
            width: MediaQuery.of(context).size.width,
            child: PhotoView(
              imageProvider: NetworkImage(image),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              initialScale: PhotoViewComputedScale.contained,
            ),
          ),
        );
      },
    );
  }

  List<dynamic> Imagess = [];
  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = getImageUrls();
    return Scaffold(
        body: ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'My Offers',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        imageUrls.isNotEmpty
            ? Column(
                children: [
                  for (int i = 0; i < imageUrls.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                      child: GestureDetector(
                        onTap: () {
                          ShowDialogBox(imageUrls[i]);
                        },
                        child: Container(
                          height: 180,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(15.0),
                              image: DecorationImage(
                                  image: NetworkImage(imageUrls[i]),
                                  fit: BoxFit.cover)),
                        ),
                      ),
                    )
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              )
      ],
    ));
  }
}
