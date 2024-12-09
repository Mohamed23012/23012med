import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:internet/screens/TestFinished.dart';
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

  String getSignalQuality(double signalValue) {
    if (signalValue <= -80) {
      return 'Great';
    } else if (signalValue <= -50) {
      return 'Good';
    } else {
      return 'Bad';
    }
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
          final source = item['_source']; // Access the '_source' field in Elasticsearch results

          // Add default fallback values for null fields
          final date = source['date'] ?? 'Unknown Date';
          final downloadSpeed = source['downloadSpeed']?.toString() ?? '0.0';
          final signalStrengthValue = source['signalStrengthValue']?.toString() ?? '0';
          final networkType = source['networkType'] ?? '';

          loadedData.add({
            'date': date,
            'download': downloadSpeed,
            'signal': double.parse(signalStrengthValue.replaceAll(" dBm", "")),
            'technology': networkType,
          });

          totalDownload += double.tryParse(downloadSpeed) ?? 0.0;
          totalSignal += double.tryParse(signalStrengthValue) ?? 0.0;
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
    // Filter history data based on selected technology
    final filteredData = _historyData
        .where((item) => item['technology'] == _selectedTechnology)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[200], // Light grey background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown and Title Row
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
                        : '4G', // Fallback to a default value
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTechnology = newValue!;
                      });
                      _loadHistoryData(); // Call the method to fetch data based on the new selection
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
                      'Total tests',
                      _totalTests.toString(),
                      Icons.check_circle,
                    ),
                  ),
                  SizedBox(width: 8), // Ajout d'un espacement entre les cartes
                  Expanded(
                    child: _buildStatCard(
                      'Download Avg',
                      '${_downloadAvg.toStringAsFixed(2)} Mbps',
                      Icons.download,
                    ),
                  ),
                  SizedBox(width: 8), // Ajout d'un espacement entre les cartes
                  Expanded(
                    child: _buildStatCard(
                      'Signal Avg',
                      '${_signalAvg.toStringAsFixed(2)} Mbps',
                      Icons.signal_cellular_alt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // History List Section
              const Text(
                'Result History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16.0),

              // History List
            Expanded(
              child: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
              final item = filteredData[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to the DetailsScreen with the selected item
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpeedTestFinishedPage(),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Type Icon
                      Icon(
                        _selectedTechnology == 'WiFi' ? Icons.wifi : Icons.speaker_phone,
                        size: 32,
                        color: Colors.blue,
                      ),

                      // Date and Download Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Download: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '${item['download']} Mbps',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                item['date'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                            ],
                          ),
                        ),
                      ),

                          // Signal Strength
                          Row(
                            children: [
                              const Icon(
                                Icons.signal_cellular_alt,
                                size: 24,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                getSignalQuality(item['signal'] ?? 0.0),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                           ),
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

  // Widget for Stats Card
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      width: 100,
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
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
