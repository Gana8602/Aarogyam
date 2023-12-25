import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cashback extends StatefulWidget {
  const Cashback({Key? key});

  @override
  State<Cashback> createState() => _CashbackState();
}

class _CashbackState extends State<Cashback> {
  String? patientID;
  int netValue = 0;
  List<Map<String, dynamic>> cashbackData1 = [];
  List<Map<String, dynamic>> cashbackData2 = [];
  List<Map<String, dynamic>> medcoinData = [];

  @override
  void initState() {
    super.initState();
    GetLocalTest().then((_) {
      if (patientID != null) {
        retrieveCashbackData();
        retrieveCashbackData2();
      } else {
        print('PatientID is null');
      }
    });
  }

  Future<void> GetLocalTest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      patientID = prefs.getString('patientID');
      print('patientid = $patientID');
    });
  }

  Future<List<Map<String, dynamic>>?> fetchData() async {
    final response = await http.get(Uri.parse(
        'http://ban58.thyroreport.com/api/Cashback/GetCashbackByPatientID?PatientID=$patientID'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print('resoponse.report: ${response.body}');
      return List<Map<String, dynamic>>.from(data);
    } else {
      print('Request failed with status: ${response.statusCode}');
      print('Response: ${response.body}');
      throw Exception('Failed to load cashback data');
    }
  }

  Future<void> retrieveCashbackData() async {
    try {
      List<Map<String, dynamic>>? data = await fetchData();
      if (data != null) {
        setState(() {
          cashbackData1 = data;
          cashbackData1.sort((a, b) {
            DateTime? dateA = DateTime.tryParse(a['createdDate'] ?? '');
            DateTime? dateB = DateTime.tryParse(b['createdDate'] ?? '');
            if (dateA != null && dateB != null) {
              return dateB.compareTo(dateA);
            }
            return 0;
          });
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> fetchData2() async {
    final response = await http.get(Uri.parse(
        'http://ban58.thyroreport.com/api/Medcoin/GetmedcoinByPatientID?PatientID=$patientID'));

    if (response.statusCode == 200) {
      List<dynamic> data2 = json.decode(response.body);
      print("response.medcoin : ${response.body}");
      return List<Map<String, dynamic>>.from(data2);
    } else {
      print('Request failed with status: ${response.statusCode}');
      throw Exception('Failed to load cashback data');
    }
  }

  Future<void> retrieveCashbackData2() async {
    try {
      List<Map<String, dynamic>>? data2 = await fetchData2();
      if (data2 != null) {
        setState(() {
          cashbackData2 = data2;
          cashbackData2.sort((a, b) {
            DateTime? dateA = DateTime.tryParse(a['createdDate'] ?? '');
            DateTime? dateB = DateTime.tryParse(b['createdDate'] ?? '');
            if (dateA != null && dateB != null) {
              return dateB.compareTo(dateA);
            }
            return 0;
          });
          calculateNetValue(cashbackData2);
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void calculateNetValue(List<Map<String, dynamic>> data) {
    int creditTotal = 0;
    int debitTotal = 0;

    for (var entry in data) {
      var action = entry['action'].toString().trim();
      var Medcoin = entry['medcoin'];

      if (action.toLowerCase() == 'credit' && Medcoin != null) {
        creditTotal += int.tryParse(Medcoin.toString()) ?? 0;
      } else if (action.toLowerCase() == 'debit' && Medcoin != null) {
        debitTotal += int.tryParse(Medcoin.toString()) ?? 0;
      }
    }

    setState(() {
      netValue = creditTotal - debitTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Lab test cashback',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                    height: 200, // Adjust the height as needed
                    width: MediaQuery.of(context).size.width,
                    child: cashbackData1.isNotEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: SingleChildScrollView(
                              child: DataTable(
                                columns: const <DataColumn>[
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Amount')),
                                ],
                                rows: cashbackData1.map((item) {
                                  DateTime? date = DateTime.tryParse(
                                      item['createdDate'] ?? '');
                                  String formattedDate = date != null
                                      ? DateFormat.yMd().format(date)
                                      : '';
                                  return DataRow(cells: [
                                    DataCell(Text(formattedDate)),
                                    DataCell(Text(item['isExpired'] ?? '')),
                                    DataCell(Text(
                                        item['cashbackAmt']?.toString() ?? '')),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          )
                        : const Center(
                            child: Text('No Data Available'),
                          )),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        'Medicine Cashback : $netValue',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    height: 200, // Adjust the height as needed
                    width: MediaQuery.of(context).size.width,
                    child: cashbackData2.isNotEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: SingleChildScrollView(
                              child: DataTable(
                                columnSpacing: 12.0,
                                columns: const <DataColumn>[
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Amount')),
                                  DataColumn(label: Text('Medcoin')),
                                  DataColumn(label: Text('Store Name'))
                                ],
                                rows: cashbackData2.map((item) {
                                  DateTime? date2 = DateTime.tryParse(
                                      item['createdDate'] ?? '');
                                  String formattedDate2 = date2 != null
                                      ? DateFormat.yMd().format(date2)
                                      : '';
                                  return DataRow(cells: [
                                    DataCell(Text(formattedDate2)),
                                    DataCell(Text(item['action'] ?? '')),
                                    DataCell(Text(
                                        item['transactionAmt']?.toString() ??
                                            '')),
                                    DataCell(Text(
                                        item['medcoin']?.toString() ?? '')),
                                    DataCell(Text(item['medLabStore'] ?? ''))
                                  ]);
                                }).toList(),
                              ),
                            ),
                          )
                        : const Center(
                            child: Text('No Data Available'),
                          )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
