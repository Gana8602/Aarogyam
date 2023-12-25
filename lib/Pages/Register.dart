import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thyrocare/main_navigation/mainpage.dart';

import '../utils/colors.dart';

class RegisterPage extends StatefulWidget {
  final String phoneNumber;
  RegisterPage({super.key, required this.phoneNumber});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? _firstName;
  String? _email;
  bool _isLoading = false;

  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _labCodeIdController =
      TextEditingController(); // Added lab code controller

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

  Future<bool> checkLabCodeAvailability(String labName) async {
    final String apiUrl =
        'http://ban58.thyroreport.com/api/LabCode/GetLabDetailsbyLabname';

    try {
      var response = await http.get(Uri.parse('$apiUrl?Labname=$labName'));

      if (response.statusCode == 200) {
        final List<dynamic> labCodes = json.decode(response.body);

        if (labCodes.isNotEmpty) {
          final labInfo = labCodes.first;
          SharedPreferences prefs = await SharedPreferences.getInstance();

          prefs.setString('smsNumber', labInfo['smsNumber']);
          prefs.setString('whatsAppNumber', labInfo['whatsAppNumber']);
          prefs.setString('labFullName', labInfo['labFullName']);
          prefs.setString('labCodeID', labInfo['labCodeID'].toString());

          print("saved sms : ${prefs.getString('smsNumber')}");
          print("saved whatsapp : ${prefs.getString('whatsAppNumber')}");
          print("saved labname : ${prefs.getString('labFullName')}");
          print("saved Id : ${prefs.getString('labCodeID').toString()}");

          return true;
        }
      } else {
        print(
            'Failed to check lab code availability. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking lab code availability: $e');
    }

    return false;
  }

  Future<int?> createPatient() async {
    String labName = _labCodeIdController.text.trim();

    try {
      if (labName.isNotEmpty && await checkLabCodeAvailability(labName)) {
        setState(() {
          _isLoading = true;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? labCodeID = prefs.getString('labCodeID').toString();
        final String apiUrl =
            'http://ban58.thyroreport.com/api/Patient/CreatePatient';

        Map<String, dynamic> patientData = {
          "patientID": 0,
          "firstName": _firstNameController.text,
          "labCodeId": labCodeID.toString(),
          "emailID": _emailController.text,
          "phoneNo": widget.phoneNumber,
          "isEnabled": "Y",
        };

        try {
          var response = await http.post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(patientData),
          );

          if (response.statusCode == 201) {
            final jsonResponse = json.decode(response.body);
            final patientID = jsonResponse['patientID'];
            await savePatientIDLocally(patientID);
            return patientID;
          } else {
            print(
                "Failed to create patient. Status code: ${response.statusCode}");
          }
        } catch (e) {
          print("Error: $e");
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print('Lab code not available. Please enter a valid lab code.');
      }
    } catch (e) {
      print('Error: $e');
      _showToast('Enter a valid labCodeID');
    }

    return null;
  }

  Future<void> savePatientIDLocally(dynamic patientID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (patientID is int) {
      prefs.setInt('patientID', patientID);
    } else if (patientID is String) {
      prefs.setString('patientID', patientID);
    }
  }

  Future<void> createCashback(int patientID) async {
    final String apiUrl =
        'http://ban58.thyroreport.com/api/Cashback/createCashback';

    final DateTime currentDate = DateTime.now();
    final formattedDate =
        '${currentDate.year}-${currentDate.month}-${currentDate.day}';

    final Map<String, dynamic> cashbackData = {
      "cashbackID": 0,
      "patientID": patientID,
      "transactionAmt": 0,
      "cashbackAmt": 200,
      "isExpired": "Available",
      "createdDate": "2023-11-13T00:00:00",
      "isEnabled": "Y",
      "createdBy": "Online",
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(cashbackData),
      );

      if (response.statusCode == 201) {
        print('Cashback created successfully!');
        print('Response: ${response.body}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainPAge(
              name: _firstNameController.text,
              onNavigation: (value) => 0,
            ),
          ),
        );
      } else {
        print('Error creating cashback. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (error) {
      print('Error creating cashback: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.BC,
      body: SingleChildScrollView(
        child: Center(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
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
                const Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 3, bottom: 20),
                  child: Text(
                    "Ready to unlock new opportunities? Let's get you registered!",
                    style: TextStyle(color: AC.TC, fontSize: 15),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10),
                  child: Text(
                    'Enter Your First Name',
                    style: TextStyle(color: AC.TC),
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
                      color: AC.BC,
                    ),
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'First Name',
                        fillColor: Colors.grey,
                        labelStyle: TextStyle(color: Colors.grey),
                        focusColor: Colors.grey,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 155, 80, 75),
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10),
                  child: Text(
                    'Enter Your Email',
                    style: TextStyle(color: AC.TC),
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
                      color: AC.BC,
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'E-mail',
                        fillColor: Colors.grey,
                        labelStyle: TextStyle(color: Colors.grey),
                        focusColor: Colors.grey,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 155, 80, 75),
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10),
                  child: Text(
                    'Enter Lab Name',
                    style: TextStyle(color: AC.TC),
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
                      color: AC.BC,
                    ),
                    child: TextFormField(
                      controller: _labCodeIdController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Lab name',
                        fillColor: Colors.grey,
                        labelStyle: TextStyle(color: Colors.grey),
                        focusColor: Colors.grey,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 155, 80, 75),
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
                          onTap: () async {
                            int? patientID = await createPatient();
                            if (patientID != null) {
                              createCashback(patientID);
                            }
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
                                'Next',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
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
