import 'package:flutter/material.dart';
import 'package:internet/screens/TestFinished.dart';
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
        const SizedBox(height: 40),
 
        // Circular Gauge with Start Test Button in Center
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    startAngle: 130,
                    endAngle: 50,
                    minimum: 0,
                    maximum: 100,
                    showLabels: false,
                    showTicks: false,
                    axisLineStyle: AxisLineStyle(
                      thickness: 0.15,
                      cornerStyle: CornerStyle.bothCurve,
                      color: Colors.grey[300]!,
                      thicknessUnit: GaugeSizeUnit.factor,
                    ),
                  ),
                ],
              ),
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
                  networkProvider.storeDataTest();

                  // Navigate to the "Test Finished" page after completing the test
                  if (mounted && networkProvider.isTestCompleted) {
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNetworkCard(
              icon: Image.asset(
                networkProvider.networkType == networkProvider.wifiName
                    ? 'assets/icons/wifi.png'
                    : 'assets/icons/signal.png',
                width: 20,
                height: 20,
              ),
              label: 'Technologie',
              value: networkProvider.networkType ?? 'N/A',
            ),
            _buildNetworkCard(
              icon: Image.asset(
                'assets/icons/glob.png',
                width: 20,
                height: 20,
              ),
              label: 'Operateur',
              value: networkProvider.operator ?? 'N/A',
            ),
            _buildNetworkCard(
              icon: Image.asset(
                'assets/icons/loc.png',
                width: 20,
                height: 20,
              ),
              label: 'Location',
              value: networkProvider.location ?? 'N/A',
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
          _buildSpeedCard(
            label: 'Download',
            value: '${networkProvider.downloadSpeed.toStringAsFixed(1)} Mbps',
            iconPath: 'assets/icons/down.png',
            isLarge: true, // Larger card
          ),
          _buildSpeedCard(
            label: 'Signal',
            value: '${networkProvider.signalStrengthValue ?? 'N/A'}',
            iconPath: 'assets/icons/signal_rate.png',
            isLarge: true, // Larger card
          ),
        ],
      ),
      const SizedBox(height: 10), // Space between rows

      // Second Row for Ping, Jitter, and Upload (Smaller Cards)
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
      const SizedBox(height: 7),

      // Circular Gauge
      Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child:
              NetworkGauge(
                downloadValue: networkProvider.downloadSpeed,
                uploadValue: networkProvider.uploadSpeed,
                downloadColor: const Color(0xFF4CAF50),
                uploadColor: const Color(0xFF1E88E5),
                backgroundColor: Colors.grey[300]!,
              ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Download',
                style: TextStyle(
                  fontSize: 16,
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
      const SizedBox(height: 5),

      // Network Informations Section
      const Text(
        'Network Informations',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNetworkCard(
            icon: Image.asset(
              networkProvider.networkType == networkProvider.wifiName
                  ? 'assets/icons/wifi.png'
                  : 'assets/icons/signal.png',
              width: 30, // Ajustez la largeur de l'image si nécessaire
              height: 20, // Ajustez la hauteur de l'image si nécessaire
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
      const SizedBox(height: 5),

      // Stop Test Button
      ElevatedButton(
        onPressed: () {
          // Add logic to stop the test here
          final networkProvider = Provider.of<NetworkProvider>(context, listen: false);
          networkProvider.stopTest();

          setState(() {
            isTesting = false;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red, // Button color
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_outlined, // Danger icon
              color: Colors.white,
              size: 22,
               // Adjust the size if necessary
            ),
            SizedBox(width: 8), // Add some space between the icon and the text
            Text(
              'STOP TEST',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ],
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
        height:120,
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

 Widget _buildSpeedCard({
    required String label,
    required String value,
    required String iconPath,
    bool isLarge = false, // Flag to determine card size
  }) {
    return Container(
      width: isLarge ? 120 : 80, // Larger width for specific cards
      height: isLarge ? 100 : 90, // Larger height for specific cards
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // Slightly rounded corners
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
            width: isLarge ? 20 : 10, // Larger icon size for large cards
            height: isLarge ? 20 : 10,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 14 : 12, // Slightly larger font for large cards
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
}
