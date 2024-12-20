import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:internet/screens/TestFinished.dart';
import 'package:internet/services/network_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _historyData = [];
  String _selectedTechnology = ""; // Initially empty
  double _downloadAvg = 0.0;
  double _signalAvg = 0.0;
  int _totalTests = 0;

  @override
  void initState() {
    super.initState();
    _initializeTechnology(); // Set initial technology from NetworkProvider
    _loadHistoryData();
  }

  void _initializeTechnology() {
    final networkProvider = Provider.of<NetworkProvider>(context, listen: false);
    setState(() {
      _selectedTechnology = networkProvider.networkType ?? "";
    });
  }

  Future<void> _loadHistoryData() async {
    try {
      final response = await http.get(
        Uri.parse('http://104.154.91.24:8000/api/retrieve-data?index_name=qualitynet'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> results = responseBody['result'];

        List<Map<String, dynamic>> loadedData = [];
        double totalDownload = 0.0;
        double totalSignal = 0.0;

        for (var item in results) {
          final source = item['_source'];
          final sort = item['sort'];

          final timestamp = sort[0] ?? 'Unknown timestamp';
          final downloadSpeed = source['downloadSpeed']?.toString() ?? '0.0';
          final signalStrengthValuee = source['signalStrengthValuee']?.toString() ?? '0';
          final uploadSpeed = source['uploadSpeed']?.toString() ?? '0.0';
          final ping = source['ping']?.toString() ?? '0.0';
          final jitter = source['jitter']?.toString() ?? '0.0';
          final place = source['place'] ?? 'Unknown place';
          final operator = source['operator'] ?? 'Unknown operator';
          final device = source['device'] ?? 'Unknown device';
          final networkType = source['networkType'] ?? '';

          loadedData.add({
            'timestamp': timestamp,
            'download': downloadSpeed,
            'signal': double.parse(signalStrengthValuee.replaceAll(" dBm", "")),
            'upload': uploadSpeed,
            'ping': ping,
            'jitter': jitter,
            'place': place,
            'operator': operator,
            'device': device,
            'technology': networkType,
          });

          totalDownload += double.tryParse(downloadSpeed) ?? 0.0;
          totalSignal += double.parse(signalStrengthValuee.replaceAll(" dBm", ""));
        }

        setState(() {
          _historyData = loadedData;
          _totalTests = loadedData.length;
          _downloadAvg = totalDownload / (_totalTests > 0 ? _totalTests : 1);
          _signalAvg = totalSignal / (_totalTests > 0 ? _totalTests : 1);
        });
      } else {
        print('Failed to fetch history data: ${response.body}');
      }
    } catch (e) {
      print('Error loading history data: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final filteredData = _historyData
        .where((item) => item['technology'] == _selectedTechnology)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Result Stats',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedTechnology.isNotEmpty &&
                            ['4G', 'WiFi', '3G'].contains(_selectedTechnology)
                        ? _selectedTechnology
                        : '4G',
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTechnology = newValue!;
                      });
                      _loadHistoryData();
                    },
                    items: ['4G', 'WiFi', '3G'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Result Stats Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total tests taken',
                      _totalTests.toString(),
                      'assets/icons/check.png',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Download Avg',
                      '${_downloadAvg.toStringAsFixed(2)} Mbps',
                      'assets/icons/down.png',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Signal Avg',
                      '${_signalAvg.toStringAsFixed(2)} dBm',
                      'assets/icons/signal_rate.png',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'Result History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Column Titles
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                color: Colors.grey[200],
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Type',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Date',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Download',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Signal',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final item = filteredData[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => SpeedTestFinishedPage(),
                        //   ),
                        // );
                      },
                      child: Container(
                        width: 100,
                        height: 80,
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 5,
                              spreadRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              item['technology'] == 'WiFi'
                                  ? 'assets/icons/wifi.png'
                                  : 'assets/icons/signal-status.png',
                              width: 30,
                              height: 30,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  '${item['timestamp'].split(' ')[0].split('-')[2]}-${item['timestamp'].
                                  split(' ')[0].split('-')[1]}-${item['timestamp'].
                                  split(' ')[0].split('-')[0]}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['timestamp'].split(' ')[1].substring(0, 5),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                            Text(
                              '${double.parse(item['download'].toString()).toStringAsFixed(2)} Mbps',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            getSignalQualityWidget(item['signal']),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String iconPath) {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, width: 20, height: 20),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget getSignalQualityWidget(double signalStrength) {
    if (signalStrength > -50) {
      return const Row(
        children: [
          Text(
            'Great',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (signalStrength > -80) {
      return const Row(
        children: [
          Text(
            'Good',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return const Row(
        children: [
          Text(
            'Bad',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
  }
}