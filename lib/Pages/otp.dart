import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thyrocare/Pages/Register.dart';
import 'package:thyrocare/main_navigation/mainpage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/colors.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final int codeLength;

  const OtpPage({
    super.key,
    required this.phoneNumber,
    required this.codeLength,
    required this.verificationId,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpController = TextEditingController();
  bool _isOtpWrong = false;
  bool _isLoading = false;

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> verifyOTP(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    FirebaseAuth auth = FirebaseAuth.instance;
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: _otpController.text.trim(),
    );

    try {
      UserCredential userCredential =
          await auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Successfully verified OTP
        await handleUserVerification();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isOtpWrong = true;
      });
      print("Failed to verify OTP: ${e.message}");
      _showToast('Failed to verify OTP: ${e.message}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> handleUserVerification() async {
    try {
      final url =
          'http://ban58.thyroreport.com/api/Patient/GetPatientByPhoneNo?PhoneNo=${widget.phoneNumber}';

      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        print("Received JSON Response: $jsonResponse");

        if (jsonResponse.isNotEmpty) {
          final user = jsonResponse.first;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('labCodeID', user['labCodeID'].toString());
          prefs.setString('patientID', user['patientID'].toString());
          prefs.setString('userName', user['firstName']);
          prefs.setString('userEmail', user['emailID']);
          prefs.setString('userPhone', user['phoneNo']);

          // Check if labCodeID is not null or empty before making the API request
          String? labCodeID = prefs.getString('labCodeID');
          if (labCodeID != null && labCodeID.isNotEmpty) {
            await fetchLabInfo(labCodeID);
          }

          navigateBasedOnUser(prefs);
        } else {
          navigateBasedOnUser(null);
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        _showToast('Failed to fetch user data');
      }
    } on http.ClientException catch (e) {
      print("Error: $e");
      _showToast('Network error: ${e.message}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchLabInfo(String labCodeID) async {
    try {
      if (labCodeID != null && labCodeID.isNotEmpty) {
        final labInfoUrl =
            'http://ban58.thyroreport.com/api/LabCode/GetLabDetailsbyLabcodeID?Labcodeid=$labCodeID';

        var labInfoResponse = await http.get(Uri.parse(labInfoUrl));

        if (labInfoResponse.statusCode == 200) {
          List<dynamic> labInfoJson = json.decode(labInfoResponse.body);
          print("Received Lab Info Response: $labInfoJson");

          if (labInfoJson.isNotEmpty) {
            final labInfo = labInfoJson.first;
            SharedPreferences prefs = await SharedPreferences.getInstance();

            // Save lab specific information
            prefs.setString('smsNumber', labInfo['smsNumber']);
            prefs.setString('whatsAppNumber', labInfo['whatsAppNumber']);
            prefs.setString('labFullName', labInfo['labFullName']);
          }
        } else {
          print(
              'Lab Info request failed with status: ${labInfoResponse.statusCode}');
          _showToast('Failed to fetch lab information');
        }
      } else {
        print('Lab Code ID is null or empty');
      }
    } on http.ClientException catch (e) {
      print("Error fetching Lab Info: $e");
      _showToast('Network error fetching lab information: ${e.message}');
    }
  }

  void navigateBasedOnUser(SharedPreferences? prefs) {
    if (prefs != null && prefs.containsKey('userName')) {
      saveSession();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainPAge(
            name: prefs.getString('userName') ?? '',
            onNavigation: (value) => 0,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterPage(
            phoneNumber: widget.phoneNumber,
          ),
        ),
      );
    }
  }

  Future<void> saveSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.white, // Change to your desired background color
      body: SingleChildScrollView(
        child: Center(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  // padding: const EdgeInsets.only(
                  //   left: 150.0,
                  // ),
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/logo.png'),
                            fit: BoxFit.cover)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15.0, bottom: 5.0, top: 20),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: AC.TC,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0, top: 3, bottom: 20),
                  child: Text(
                    "We have Sent a OTP to Your Phone Number, You Entered +91 ${widget.phoneNumber},  to edit go back",
                    style: const TextStyle(color: AC.TC, fontSize: 15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 10),
                  child: Text(
                    'Enter Your Otp',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
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
                    child: TextFormField(
                      controller: _otpController,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Otp',
                        fillColor: Colors.grey,
                        labelStyle: const TextStyle(color: Colors.grey),
                        focusColor: Colors.grey,
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(
                            color: _isOtpWrong
                                ? const Color.fromARGB(255, 236, 32, 17)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                Stack(
                  children: [
                    Visibility(
                      visible: !_isLoading,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: GestureDetector(
                          onTap: () {
                            verifyOTP(context);
                          },
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            child: const Center(
                              child: Text(
                                'Get Started',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _isLoading,
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
