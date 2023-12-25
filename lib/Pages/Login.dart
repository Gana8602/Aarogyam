import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:thyrocare/main_navigation/mainpage.dart';
import 'package:thyrocare/Pages/otp.dart';
import 'package:thyrocare/utils/colors.dart';

class RegistrationPage extends StatefulWidget {
  RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

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

  Future<void> verifyPhoneNumber(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    FirebaseAuth auth = FirebaseAuth.instance;

    String phoneNumber = _phoneNumberController.text.trim();

    if (phoneNumber.isEmpty) {
      _showToast("Please enter your phone number.");
      return;
    }

    if (phoneNumber.length != 10) {
      _showToast("Please enter a 10-digit phone number.");
      return;
    }

    await auth.verifyPhoneNumber(
      phoneNumber: '+91${phoneNumber}',
      verificationCompleted: (PhoneAuthCredential credential) {
        // Handle automatic verification or auto-retrieval of the code
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle verification failure
        print("Verification Failed: ${e.message}");
        _isLoading = false;
      },
      codeSent: (String verificationId, int? resendToken) {
        // Navigate to OTP verification page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpPage(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
              codeLength: 4,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle timeout or start the code retrieval process again
      },
    );
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
                  // padding: const EdgeInsets.only(left: 150.0, top: 50),
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
                    'Welcome to \nAAROGYAM',
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
                    "Ready to unlock new opportunities? Let's get you in!",
                    style: TextStyle(color: AC.TC, fontSize: 15),
                  ),
                ),
                // const Padding(
                //   padding: EdgeInsets.only(left: 15.0, top: 10),
                //   child: Text(
                //     'Enter Your Name',
                //     style: TextStyle(color: AC.TC),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.all(15.0),
                //   child: Container(
                //     decoration: BoxDecoration(
                //       boxShadow: [
                //         BoxShadow(
                //           color:
                //               Colors.grey.withOpacity(0.5), // Light grey shadow
                //           spreadRadius: 2,
                //           blurRadius: 4,
                //           offset: const Offset(
                //               0, 4), // Changes the position of the shadow
                //         ),
                //       ],
                //       borderRadius: const BorderRadius.all(Radius.circular(15)),
                //       color: AC.BC,
                //     ),
                //     child: TextFormField(
                //       controller: _nameController,
                //       decoration: const InputDecoration(
                //         floatingLabelBehavior: FloatingLabelBehavior.never,
                //         labelText: 'Name',
                //         fillColor: Colors.grey,
                //         labelStyle: TextStyle(color: Colors.grey),
                //         focusColor: Colors.grey,
                //         focusedBorder: OutlineInputBorder(
                //           borderRadius: BorderRadius.all(Radius.circular(15)),
                //           borderSide: BorderSide(color: Colors.transparent),
                //         ),
                //         enabledBorder: OutlineInputBorder(
                //           borderRadius: BorderRadius.all(Radius.circular(15)),
                //           borderSide: BorderSide(color: Colors.transparent),
                //         ),
                //         errorBorder: OutlineInputBorder(
                //           borderRadius: BorderRadius.all(Radius.circular(15)),
                //           borderSide: BorderSide(
                //             color: Color.fromARGB(255, 155, 80, 75),
                //           ),
                //         ),
                //       ),
                //       style: const TextStyle(color: Colors.black),
                //     ),
                //   ),
                // ),
                const Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10),
                  child: Text(
                    'Enter Your Phone Number',
                    style: TextStyle(color: AC.TC),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.grey.withOpacity(0.5), // Light grey shadow
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(
                              0, 4), // Changes the position of the shadow
                        ),
                      ],
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      color: AC.BC,
                    ),
                    child: TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Phone Number',
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
                          onTap: () {
                            verifyPhoneNumber(context);
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
