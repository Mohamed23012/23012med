import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/network_provider.dart';
import '../widgets/network_gauge.dart';
import '../services/network_provider.dart';
class SpeedTestFinishedPage extends StatelessWidget {
  const SpeedTestFinishedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'ALL FINISHED',
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Upload and Download Speeds
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpeedInfo(
                  'Upload',
                  '${networkProvider.uploadSpeed.toStringAsFixed(1)} Mbps',
                  Icons.cloud_upload,
                ),
                _buildSpeedInfo(
                  'Download',
                  '${networkProvider.downloadSpeed.toStringAsFixed(1)} Mbps',
                  Icons.cloud_download,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Ping, Jitter, and Mbps
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpeedInfo('Ping', '${networkProvider.ping.toStringAsFixed(1)} ms', Icons.timer),
                _buildSpeedInfo('Jitter', '${networkProvider.jitter.toStringAsFixed(1)} ms', Icons.speed),
                _buildSpeedInfo(
                  'Signal',
                  '${networkProvider.signalStrengthValue}',
                  Icons.network_check,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Banner Image
            Container(
              height: 120,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/Capture.png'), // Replace with your image path
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            const SizedBox(height: 20),

            // Network Information Section
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
              icon: Icons.wifi,
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
            const SizedBox(height: 20),

            // Test Again Button
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await networkProvider.retrieveLocation();
                await networkProvider.fetchOperatorInfo();
                await networkProvider.networkmetrics();
                await networkProvider.startTest();
                networkProvider.storeData();// Return to the main screen to restart the test
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
                'TEST AGAIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
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
}
