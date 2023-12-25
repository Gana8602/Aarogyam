import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thyrocare/utils/colors.dart';

class AarogyamPackage extends StatefulWidget {
  const AarogyamPackage({super.key});

  @override
  State<AarogyamPackage> createState() => _AarogyamPackageState();
}

class _AarogyamPackageState extends State<AarogyamPackage> {
  List<dynamic> Imagess = []; // Initialize Imagess as an empty list
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
      print('saved code : $savedLabCodeID');
      GetImages();
    });
  }

  Future<void> GetImages() async {
    final url =
        'http://ban58.thyroreport.com/api/AarogyamPackage/GetAarogyamPackagebyLabcodeid?Labcodeid=$savedLabCodeID';

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
        'http://ban58files.thyroreport.com/${savedLabCodeID}/UploadedFiles/OfferPackage';

    return Imagess.map<String>((dynamic image) {
      String imageName = image['aarogyamPackageFileName'];
      String imageUrl = '$imgPath/$imageName'; // Change this line
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

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = getImageUrls();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aarogyam Package',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AC.TC,
      ),
      body: SingleChildScrollView(
        child: imageUrls.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                children: [
                  for (int i = 0; i < imageUrls.length; i++)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () {
                          ShowDialogBox(imageUrls[i]);
                        },
                        child: Container(
                          height: 400,
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
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
