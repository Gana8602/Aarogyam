import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thyrocare/Pages/Aarogyam.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thyrocare/Pages/Contact.dart';
import 'package:thyrocare/Pages/Login.dart';

import 'package:thyrocare/Pages/Monthly_offer.dart';
import 'package:thyrocare/Pages/Report.dart';
import 'package:thyrocare/Pages/Test_Rate.dart';
import 'package:thyrocare/Pages/cashback.dart';
import 'package:http/http.dart' as http;
import 'package:thyrocare/Pages/offer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thyrocare/Pages/store.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../Pages/Doctors.dart';
import '../utils/colors.dart';

class MainPAge extends StatefulWidget {
  final String name;

  final ValueChanged<int> onNavigation;

  const MainPAge({
    required this.name,
    required this.onNavigation,
  });

  @override
  State<MainPAge> createState() => _MainPAgeState();

  static of(BuildContext context) {}
}

class _MainPAgeState extends State<MainPAge> {
  int _myCurrentIndex = 0;
  String popup = '';
  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  late List<Widget> pages;
  String? savedLabCodeID;
  String appName = "";
  String phone = "";
  @override
  void initState() {
    super.initState();
    pages = [
      homePage(navigationKey: navigationKey),
      const Report(),
      const Cashback(),
      const Offers(),
      const ContactUs(),
    ];

    // _checkAndRequestPermissions();
    getSavedLabCodeID();
    // _checkIfOfferShown();
  }

  Future<void> getSavedLabCodeID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedLabCodeID = prefs.getString('labCodeID');
      appName = prefs.getString('labFullName') ?? '';
      phone = prefs.getString('smsNumber')!;
      _PopUpImageUrl();
    });
  }

  Future<void> _PopUpImageUrl() async {
    try {
      // Fetch the JSON response from your API
      final response = await http.get(Uri.parse(
          'http://ban58.thyroreport.com/api/AdPopup/GetPopupImagebyLabcodeid?Labcodeid=$savedLabCodeID'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          final firstItem = data[0];
          final filename = firstItem['adPopupFilename'];

          // Construct the complete URL for the image using the retrieved filename
          popup =
              'http://ban58files.thyroreport.com/$savedLabCodeID/UploadedFiles/OfferPackage/$filename';
          print('Image URL: $popup');
          setState(() {
            _showOfferPopup();
          });
        }
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      print('Error fetching image: $e');
    }
  }

  Future<void> _showOfferPopup() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Color.fromARGB(0, 216, 216, 216).withOpacity(0.10),
            content: popup.isNotEmpty
                ? Container(
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(popup), fit: BoxFit.fill)))
                : const CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Check if the current page is MainPAge, and if so, close the app
        if (_myCurrentIndex == 0) {
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: AppBar(
            title: Text(
              appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: SafeArea(
                child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0033cc),
              ),
            )),
          ),
        ),
        drawer: MyDrawer(
          changePage: (index) {
            setState(() {
              _myCurrentIndex = index;
            });
          },
          text: widget.name,
          phone: phone,
        ),
        body: pages[_myCurrentIndex],
        bottomNavigationBar: CurvedNavigationBar(
          key: navigationKey,
          index: _myCurrentIndex,
          height: 60.0,
          items: const <Widget>[
            Icon(
              Icons.home,
              size: 20,
              color: Color(0xFF121e19),
            ),
            Icon(
              Icons.assignment_outlined,
              size: 20,
              color: Color(0xFF121e19),
            ),
            Icon(
              Icons.account_balance_wallet,
              size: 20,
              color: Color(0xFF121e19),
            ),
            Icon(
              Icons.local_offer_outlined,
              size: 20,
              color: Color(0xFF121e19),
            ),
            Icon(
              Icons.phone,
              size: 20,
              color: Color(0xFF121e19),
            ),
          ],
          color: Colors.white,
          buttonBackgroundColor: Colors.white,
          backgroundColor: Colors.blueAccent,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          onTap: (index) {
            setState(() {
              _myCurrentIndex = index;
            });
          },
          letIndexChange: (index) => true,
        ),
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  final String text;
  final String phone;
  final void Function(int) changePage;
  const MyDrawer(
      {required this.text, required this.changePage, required this.phone});

  makePhoneCall(String phoneNumber) async {
    if (await launchUrlString('tel:$phoneNumber')) {
      await launch('tel:$phoneNumber');
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => RegistrationPage()),
        (route) => false, // Clear the navigation stack
      );
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF0033cc),
            ),
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      image: DecorationImage(
                          image: AssetImage('assets/profile.png'),
                          fit: BoxFit.cover)),
                ),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainPAge(
                            name: text,
                            onNavigation: (int value) {},
                          )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_sharp),
            title: const Text('My Report'),
            onTap: () {
              changePage(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.money_outlined),
            title: const Text('Cashback'),
            onTap: () {
              changePage(2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.thermometer),
            title: const Text('Test Rate'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const TestRate()));
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.rays),
            title: const Text('Offers'),
            onTap: () {
              changePage(3);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shop_2_outlined),
            title: const Text('Medical Store'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MedicalStoresPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.medical_information_outlined),
            title: const Text('Doctors'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DoctorPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_phone_outlined),
            title: const Text('Contact Us'),
            onTap: () {
              Get.to(makePhoneCall(phone));
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Log Out'),
            onTap: () {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
}

class homePage extends StatefulWidget {
  final GlobalKey<CurvedNavigationBarState> navigationKey;
  const homePage({
    super.key,
    required this.navigationKey,
  });

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  int netValue = 0;
  String? patientID;
  String? savedLabCodeID;
  String phoneNumber = '';
  String whatsappNumber = '';

  List<Map<String, dynamic>> testData = [];
  @override
  void initState() {
    super.initState();

    GetIamges();
    GetIamges2();
    retrieveUserData();
    retrieveCashbackData();
    getSavedLabCodeID();
    fetchAndSetTestData();
    fetchPatientID().then((id) {
      if (id != null) {
        fetchMedcoinData(id).then((data) {
          setState(() {
            medcoinData = data;
          });
          calculateNetValue(medcoinData);
        }).catchError((error) {
          print('Error fetching medcoin data: $error');
        });
      } else {
        print('PatientID is null');
      }
    });
  }

  Future<void> getSavedLabCodeID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedLabCodeID = prefs.getString('labCodeID');
      phoneNumber = prefs.getString('smsNumber') ?? "";
      whatsappNumber = prefs.getString('whatsAppNumber') ?? "";
    });
  }

  Future<String?> fetchPatientID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic storedPatientID = prefs.get('patientID');

    // Convert the stored value to a string
    String? patientID = storedPatientID?.toString();

    print('patientID: $patientID');
    return patientID;
  }

  Future<void> ShowDialogBox(String image) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          title: Text(
            'Zoom to View',
            style: TextStyle(color: Colors.white),
          ),
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

  Future<void> ShowDialogBox2(String image) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          title: Text(
            'Zoom to View',
            style: TextStyle(color: Colors.white),
          ),
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

  Future<List<Map<String, dynamic>>> fetchTestData() async {
    final response = await http.get(
        Uri.parse('http://ban58.thyroreport.com/api/LabTest/GetActiveTest'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchAndSetTestData() async {
    try {
      List<Map<String, dynamic>> data = await fetchTestData();
      setState(() {
        testData = data;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> GetLocalTest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      patientID = prefs.getString('patientID');
      print('patientid = $patientID');
    });
  }

  Future<void> retrieveCashbackData() async {
    try {
      String? patientID = await fetchPatientID();
      print('Patient ID in retrieveCashbackData: $patientID');

      if (patientID != null) {
        List<Map<String, dynamic>> data = await fetchData(patientID);
        setState(() {
          availableResponses = data;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchData(String patientID) async {
    final response = await http.get(Uri.parse(
        'http://ban58.thyroreport.com/api/Cashback/GetCashbackByPatientID?PatientID=$patientID'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print(response.body);
      List<Map<String, dynamic>> availableResponses = data
          .where((item) => item['isExpired'].trim() == "Available")
          .toList()
          .cast<Map<String, dynamic>>();
      return availableResponses;
    } else {
      print('Request failed with status: ${response.statusCode}');
      print('Response: ${response.body}');
      throw Exception('Failed to load cashback data');
    }
  }

  Future<void> retrieveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      patientID = prefs.getString('patientID');
      print('patientID = $patientID');
      if (patientID != null) {
        retrieveCashbackData();
      }
    });
  }

  Future<void> GetIamges() async {
    final url = 'http://ban58.thyroreport.com/api/Offer/GetAllOffer';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      print('offers  data : ${response.body}');
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
    final String imgPath1 =
        'http://ban58files.thyroreport.com/${savedLabCodeID}/UploadedFiles/OfferPackage/';
    return Imagess.map<String>((dynamic image) {
      String imageName = image['offerFileName'];
      String imageUrl = imgPath1 + imageName;
      return imageUrl;
    }).toList();
  }

  Future<void> GetIamges2() async {
    final url = 'http://ban58.thyroreport.com/api/Package/GetAllPackage';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List jsonData2 = json.decode(response.body);
      print(response.body);
      if (jsonData2.isNotEmpty) {
        setState(() {
          Imagess22 = jsonData2;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userData', json.encode(jsonData2));
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  List<String> getImageUrls2() {
    final String imgPath2 =
        'http://ban58files.thyroreport.com/${savedLabCodeID}/UploadedFiles/OfferPackage/';
    return Imagess22.map<String>((dynamic image) {
      String imageName2 = image['packageFileName'];
      String imageUrl2 = imgPath2 + imageName2;
      return imageUrl2;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchMedcoinData(String patientID) async {
    final response = await http.get(Uri.parse(
        'http://ban58.thyroreport.com/api/Medcoin/GetmedcoinByPatientID?PatientID=$patientID'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print('Medcoin data: $data');
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load medcoin data');
    }
  }

  void calculateNetValue(List<Map<String, dynamic>> data) {
    int creditTotal = 0;
    int debitTotal = 0;

    for (var entry in data) {
      print('Entry: $entry');
      var action = entry['action'].toString().trim();
      var Medcoin = entry['medcoin'];

      if (action.toLowerCase() == 'credit' && Medcoin != null) {
        creditTotal += int.tryParse(Medcoin.toString()) ?? 0;
        print('Credit added: $Medcoin');
      } else if (action.toLowerCase() == 'debit' && Medcoin != null) {
        debitTotal += int.tryParse(Medcoin.toString()) ?? 0;
        print('Debit deducted: $Medcoin');
      }
      setState(() {
        netValue = creditTotal - debitTotal;
      });
    }
  }

  List<Map<String, dynamic>> medcoinData = [];
  List<Map<String, dynamic>> availableResponses = [];
  List<Map<String, dynamic>> cashbackData = [];
  List<dynamic> Imagess = [];
  List<dynamic> Imagess22 = [];
  final List<IconData> icons1 = [
    // Icons.home,
    Icons.assignment_outlined,
    Icons.account_balance_wallet,
    Icons.local_offer_outlined,
    Bootstrap.calendar2_month,
    Icons.water_drop_sharp,
    Icons.card_giftcard_sharp,
  ];
  final List<IconData> icons2 = [
    Iconsax.whatsapp,
    Icons.contact_phone_outlined,
  ];
  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = getImageUrls();
    List<String> imageUrls2 = getImageUrls2();
    return Scaffold(
      body: ListView(
        children: [
          Container(
            height: 300,
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/wave.png'),
              fit: BoxFit.cover,
            )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'Lab Test Cashback',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'Medicine Cashback',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    availableResponses.isNotEmpty
                        ? Padding(
                            padding:
                                const EdgeInsets.only(left: 60.0, bottom: 20.0),
                            child: Text(
                              '₹ ${availableResponses.first['cashbackAmt']}', // Adjust this line
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white60),
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(left: 50.0),
                            child: Text(
                              "0",
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white60),
                            )),
                    const Spacer(),
                    medcoinData.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(
                                right: 15.0, bottom: 10.0),
                            child: Text(
                              '₹ ${netValue}', // Adjust this line
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white60),
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(right: 15.0),
                            child: Text(
                              "0",
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white60),
                            ),
                          ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                imageUrls.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.only(
                          top: 3.0,
                        ),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            aspectRatio: 15 / 6,
                            viewportFraction: 0.8,
                            enableInfiniteScroll: true,
                            autoPlay: true,
                          ),
                          items: imageUrls.map((dynamic imageUrl) {
                            return Builder(
                              builder: (BuildContext context) {
                                return GestureDetector(
                                  onTap: () {
                                    ShowDialogBox(imageUrl);
                                  },
                                  child: Container(
                                    height: 100,
                                    width: MediaQuery.of(context).size.width,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                              imageUrl,
                                            ),
                                            fit: BoxFit.fill)),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.3,
            ),
            itemBuilder: (BuildContext context, int index) {
              return GridItemWidget(
                index: index + 0,
                iconData: icons1[index],
                navigationKey: widget.navigationKey,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                height: 150,
                width: 350,
                decoration: const BoxDecoration(
                    gradient: AC.grBG,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: const Center(
                          child: Text(
                            'Contact Us',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 2,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.2,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return GridItemWidget2(
                            index: index + 0,
                            iconData: icons2[index],
                            phone: phoneNumber,
                            whatsapp: whatsappNumber,
                          );
                        },
                      ),
                    ])),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Monthly Offers',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
              height: 220,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls2.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        ShowDialogBox2(imageUrls2[index]);
                      },
                      child: Container(
                        height: 200,
                        width: 180,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imageUrls2[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  gradient: AC.TestBg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Test Rate',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                      height: 80,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: testData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, bottom: 8.0),
                            child: Container(
                              height: 50,
                              width: 160,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    testData[index]['testName'],
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    testData[index]['cost'].toString(),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

class GridItemWidget extends StatelessWidget {
  final int index;
  final IconData iconData;
  final GlobalKey<CurvedNavigationBarState> navigationKey;
  const GridItemWidget({
    required this.index,
    required this.navigationKey,
    required this.iconData,
  });

  void _makePhoneCall(String phoneNumber) async {
    if (await launchUrlString('tel:$phoneNumber')) {
      await launch('tel:$phoneNumber');
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  launchWhatsAppString() async {
    const link = WhatsAppUnilink(
      phoneNumber: '+91 7892812565',
      text: "Hey! I'm inquiring about the apartment listing",
    );

    await launchUrlString('$link');
  }

  @override
  Widget build(BuildContext context) {
    List<String> Title = [
      'My Reports',
      'Cashback',
      'Offers',
      'Monthly Offers',
      'Blood test',
      'Aarogyam Package',
    ];
    List<Color> colours = [
      Colors.black,
      Colors.brown,
      Colors.black,
      Colors.black,
      Colors.redAccent,
      Colors.black
    ];

    return Center(
      child: GestureDetector(
        onTap: () {
          switch (index) {
            case 0:
              final navigationState = navigationKey.currentState!;
              navigationState.setPage(1);

            case 1:
              final navigationState = navigationKey.currentState!;
              navigationState.setPage(2);

              break;
            case 2:
              final navigationState = navigationKey.currentState!;
              navigationState.setPage(3);

              break;
            case 3:
              Get.to(const MonthlyOffer());

              break;
            case 4:
              Get.to(const TestRate());

              break;

            case 5:
              Get.to(const AarogyamPackage());

              break;
            default:
              break;
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    iconData,
                    size: 25,
                    color: colours[index],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 80,
                  child: Text(
                    softWrap: true,
                    Title[index],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GridItemWidget2 extends StatelessWidget {
  final int index;
  final String phone;
  final String whatsapp;
  final IconData iconData;
  const GridItemWidget2(
      {required this.index,
      required this.iconData,
      required this.phone,
      required this.whatsapp});

  makePhoneCall(String phoneNumber) async {
    if (await launchUrlString('tel:$phoneNumber')) {
      await launch('tel:$phoneNumber');
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  launchWhatsAppString(String whatsApp) async {
    final link = WhatsAppUnilink(
      phoneNumber: whatsApp,
      text: "Hey! I'm inquiring about the apartment listing",
    );

    await launchUrlString(link.toString());
  }

  @override
  Widget build(BuildContext context) {
    List<String> Title = [
      'Whatsapp',
      'Call Us',
    ];
    List<Color> Colour = [
      Colors.green,
      Colors.red,
    ];

    return Center(
      child: GestureDetector(
        onTap: () {
          switch (index) {
            case 0:
              Get.to(launchWhatsAppString(whatsapp));

              break;
            case 1:
              Get.to(makePhoneCall(phone));

              break;

            default:
              break;
          }
        },
        child: Container(
          height: 60,
          width: 150,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  iconData,
                  size: 30,
                  color: Colour[index],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                Title[index],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
