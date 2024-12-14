import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const DetailsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Result Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {
              // Add share functionality here
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Date
            Text(
              result['date'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 2),

            // Download and Signal Speeds
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpeedCard(
                  label: 'Download',
                  value: '${result['download']} Mbps',
                  iconPath: 'assets/icons/down.png',
                  isLarge: true,
                ),
                _buildSpeedCard(
                  label: 'Signal',
                  value: '${result['signale']}',
                  iconPath: 'assets/icons/signal_rate.png',
                  isLarge: true,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Ping, Jitter, and Mbps
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpeedCard(
                  label: 'Ping',
                  value: '${double.parse(result['ping'].toString()).toStringAsFixed(2)} ms',
                  iconPath: 'assets/icons/ping.png',
                ),
                _buildSpeedCard(
                  label: 'Jitter',
                  value: '${double.parse(result['jitter'].toString()).toStringAsFixed(2)} ms',
                  iconPath: 'assets/icons/jitter.png',
                ),
                _buildSpeedCard(
                  label: 'Upload',
                  value: '${double.parse(result['upload'].toString()).toStringAsFixed(2)} Mbps',
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
                _buildNetworkCard(
                  icon: Image.asset(
                    result['technology'] == 'WiFi'
                        ? 'assets/icons/wifi.png'
                        : 'assets/icons/signal.png',
                    width: 20,
                    height: 20,
                  ),
                  label: 'Technologie',
                  value: result['technology'] ?? '',
                ),
                _buildNetworkCard(
                  icon: Image.asset(
                    'assets/icons/glob.png',
                    width: 20,
                    height: 20,
                  ),
                  label: 'Opérateur',
                  value: result['operator'] ?? '',
                ),
                _buildNetworkCard(
                  icon: Image.asset(
                    'assets/icons/devices.png',
                    width: 20,
                    height: 20,
                  ),
                  label: 'device',
                  value: result['device'] ?? '',
                ),
                _buildNetworkCard(
                  icon: Image.asset(
                    'assets/icons/loc.png',
                    width: 20,
                    height: 20,
                  ),
                  label: 'Location',
                  value: result['place'] ?? '',
                ),
              ],
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
        height: 150,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(10),
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
