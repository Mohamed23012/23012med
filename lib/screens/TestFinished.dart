import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                _buildSpeedCard(
                  label: 'Download',
                  value: '${networkProvider.downloadSpeed.toStringAsFixed(1)} Mbps',
                  iconPath: 'assets/icons/down.png',
                  isLarge: true, // Larger card
                ),
                _buildSpeedCard(
                  label: 'Signal',
                  value: '${networkProvider.signalStrengthValue ?? ''}',
                  iconPath: 'assets/icons/signal_rate.png',
                  isLarge: true, // Larger card
                ),
              ],
            ),
            const SizedBox(height: 10), // Space between rows

            // Ping, Jitter, and Upload (Smaller Cards)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpeedCard(
                  label: 'Ping',
                  value: '${networkProvider.ping.toStringAsFixed(1)} ms',
                  iconPath: 'assets/icons/ping.png',
                ),
                _buildSpeedCard(
                  label: 'Jitter',
                  value: '${networkProvider.jitter.toStringAsFixed(1)} ms',
                  iconPath: 'assets/icons/jitter.png',
                ),
                _buildSpeedCard(
                  label: 'Upload',
                  value: '${networkProvider.uploadSpeed.toStringAsFixed(1)} Mbps',
                  iconPath: 'assets/icons/up.png',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Banner Image
            Container(
              height: 120,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/Capture.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            const SizedBox(height: 10),

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
                _buildNetworkCard(
                  icon: Image.asset(
                    networkProvider.networkType == networkProvider.wifiName
                        ? 'assets/icons/wifi.png'
                        : 'assets/icons/signal.png',
                    width: 30,
                    height: 30,
                  ),
                  label: 'Technologie',
                  value: networkProvider.networkType ?? '',
                ),
                _buildNetworkCard(
                  icon: Image.asset(
                    'assets/icons/glob.png',
                    width: 30,
                    height: 30,
                  ),
                  label: 'Opérateur',
                  value: networkProvider.operator ?? '',
                ),
                _buildNetworkCard(
                  icon: Image.asset(
                    'assets/icons/loc.png',
                    width: 30,
                    height: 30,
                  ),
                  label: 'Location',
                  value: networkProvider.location ?? '',
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
                networkProvider.storeDataTest(); // Restart the test
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
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

  Widget _buildSpeedCard({
    required String label,
    required String value,
    required String iconPath,
    bool isLarge = false,
  }) {
    return Container(
      width: isLarge ? 140 : 80,
      height: isLarge ? 110 : 90,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: isLarge ? 20 : 10,
            height: isLarge ? 20 : 10,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 14 : 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkCard({
    required Widget icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        width:120,
        height:160,
        margin: const EdgeInsets.symmetric(horizontal: 5), // Espacement entre les cartes
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            icon,
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
