import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TestRate extends StatefulWidget {
  const TestRate({Key? key}) : super(key: key);

  @override
  State<TestRate> createState() => _TestRateState();
}

class _TestRateState extends State<TestRate> {
  List<Map<String, dynamic>> testData = [];
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
      fetchAndSetTestData();
    });
  }

  Future<List<Map<String, dynamic>>> fetchTestData() async {
    final response = await http.get(Uri.parse(
        'http://ban58.thyroreport.com/api/LabTest/GetActiveTestbyLabcodeid?Labcodeid=$savedLabCodeID'));

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
      // Handle error or show a message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Test Details',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF0033cc),
      ),
      body: testData.isEmpty
          ? Center(child: Text(" No Data Available"))
          : ListView(
              children: testData.map((item) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: Text(item['testName']),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(item['cost'].toString()),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
