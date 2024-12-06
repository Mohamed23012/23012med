import 'package:flutter/material.dart';
import 'package:internet/screens/Test%20Finished.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../services/network_provider.dart';
import '../widgets/network_gauge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isTesting = false; // State to toggle between layouts
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeNetworkInfo(); // Fetch network information on startup
  }

  Future<void> _initializeNetworkInfo() async {
    final networkProvider = Provider.of<NetworkProvider>(context, listen: false);

    try {
      // Fetch network information
      await networkProvider.retrieveLocation();
      await networkProvider.fetchOperatorInfo();

      setState(() {
        isLoading = false; // Set loading to false when data is ready
      });
    } catch (e) {
      print('Error fetching network info: $e');
      setState(() {
        isLoading = false; // Still stop loading even if there's an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: const Text(
          'QUALITY NET',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Notification action
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: isTesting
            ? _buildTestingLayout(networkProvider)
            : _buildInitialLayout(networkProvider),
      ),
    );
  }

  Widget _buildInitialLayout(NetworkProvider networkProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Top Banner Image
        Container(
          height: 120,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/Capture.png'), // Replace with your image asset path
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        const SizedBox(height: 20),
 
        // Circular Gauge with Start Test Button in Center
        Stack(
          alignment: Alignment.center,
          children: [
            NetworkGauge(
              downloadValue: networkProvider.downloadSpeed,
              uploadValue: networkProvider.uploadSpeed,
              downloadColor: const Color(0xFF1E88E5),
              uploadColor: const Color(0xFF4CAF50),
              backgroundColor: Colors.grey[300]!,
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isTesting = true; // Set testing mode to true
                });

                try {
                  // Perform speed test operations
                  await networkProvider.retrieveLocation();
                  await networkProvider.fetchOperatorInfo();
                  await networkProvider.networkmetrics();
                  await networkProvider.startTest();
                  networkProvider.storeData();

                  // Navigate to the "Test Finished" page after completing the test
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SpeedTestFinishedPage(), // Replace with your "Test Finished" page class
                      ),
                    );
                  }
                } catch (e) {
                  print("Error during speed test: $e");
                } finally {
                  setState(() {
                    isTesting = false; // Reset testing state (if necessary)
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5), // Blue button color
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'START TEST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),

        // Network Informations Section
        const Text(
          'Network Informations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNetworkInfoCard(
              icon: networkProvider.networkType ==
                            networkProvider.wifiName
                        ? Icons.wifi
                        : Icons.speaker_phone,
              label: 'Technologie',
              value: networkProvider.networkType ?? '',
            ),
            _buildNetworkInfoCard(
              icon: Icons.business,
              label: 'Opérateur',
              value: networkProvider.operator ?? '',
            ),
            _buildNetworkInfoCard(
              icon: Icons.location_on,
              label: 'Location',
              value: networkProvider.location ?? '',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestingLayout(NetworkProvider networkProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Upload and Download Speeds
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSpeedInfo('Upload', networkProvider.uploadSpeed.toStringAsFixed(1), Icons.cloud_upload),
            _buildSpeedInfo('Download', networkProvider.downloadSpeed.toStringAsFixed(1), Icons.cloud_download),
          ],
        ),
        const SizedBox(height: 20),

        // Ping, Jitter, and Mbps
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSpeedInfo('Ping', '${networkProvider.ping.toStringAsFixed(1)} ms', Icons.timer),
            _buildSpeedInfo('Jitter', '${networkProvider.jitter.toStringAsFixed(1)} ms', Icons.speed),
            _buildSpeedInfo('Signal', '${networkProvider.signalStrengthValue}', Icons.network_check),
          ],
        ),
        const SizedBox(height: 30),

        // Circular Gauge
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    startAngle: 180,
                    endAngle: 0,
                    minimum: 0,
                    maximum: 200,
                    showLabels: false,
                    showTicks: false,
                    axisLineStyle: AxisLineStyle(
                      thickness: 0.15,
                      cornerStyle: CornerStyle.bothCurve,
                      color: Colors.grey[300]!,
                      thicknessUnit: GaugeSizeUnit.factor,
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: networkProvider.downloadSpeed,
                        cornerStyle: CornerStyle.bothCurve,
                        width: 0.15,
                        sizeUnit: GaugeSizeUnit.factor,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Download',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${networkProvider.downloadSpeed.toStringAsFixed(1)} Mbps',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 30),

        // Network Informations Section
        const Text(
          'Network Informations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNetworkInfoCard(
              icon: networkProvider.networkType ==
                            networkProvider.wifiName
                        ? Icons.wifi
                        : Icons.speaker_phone,
              label: 'Technologie',
              value: networkProvider.networkType ?? 'Unknown',
            ),
            _buildNetworkInfoCard(
              icon: Icons.business,
              label: 'Opérateur',
              value: networkProvider.operator ?? 'Unknown',
            ),
            _buildNetworkInfoCard(
              icon: Icons.location_on,
              label: 'Location',
              value: networkProvider.location ?? 'Unknown',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNetworkInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blueAccent),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSpeedInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
