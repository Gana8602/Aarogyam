import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  void initState() {
    super.initState();
    call();
  }

  Future<void> call() async {
    Future.delayed(const Duration(seconds: 1), () {
      _makePhoneCall('+917891812565');
    });
  }

  void _makePhoneCall(String phoneNumber) async {
    if (await launchUrlString('tel:$phoneNumber')) {
      await launch('tel:$phoneNumber');
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Text('Hello, Please Wait... You Will be redirect to Contact Us'),
    ));
  }
}
