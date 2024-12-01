// import 'package:flutter/material.dart';

// class SpeedTestApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Quality Net',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool isTesting = false; // État pour déterminer la page affichée

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('QUALITY NET'),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications, color: Colors.black),
//             onPressed: () {
//               // Action de notification
//             },
//           ),
//         ],
//       ),
//       body: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 500),
//         transitionBuilder: (Widget child, Animation<double> animation) {
//           return SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(1.0, 0.0),
//               end: Offset.zero,
//             ).animate(animation),
//             child: child,
//           );
//         },
//         child: isTesting ? _buildTestingPage() : _buildInitialPage(),
//       ),
//     );
//   }

//   Widget _buildInitialPage() {
//     return Column(
//       key: const ValueKey('InitialPage'), // Clé pour identifier la page
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Bannière en haut
//         Container(
//           height: 120,
//           margin: const EdgeInsets.all(16.0),
//           decoration: BoxDecoration(
//             image: const DecorationImage(
//               image: AssetImage('assets/banner.png'), // Chemin de l'image
//               fit: BoxFit.cover,
//             ),
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//         ),
//         const SizedBox(height: 20),

//         // Bouton Start Test
//         Stack(
//           alignment: Alignment.center,
//           children: [
//             Container(
//               width: 200,
//               height: 200,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.grey[200],
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   isTesting = true;
//                 });
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1E88E5), // Bleu
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24.0,
//                   vertical: 12.0,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//               ),
//               child: const Text(
//                 'START TEST',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 30),

//         // Informations sur le réseau
//         const Text(
//           'Network Informations',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildNetworkInfoCard(
//               icon: Icons.wifi,
//               label: 'Technologie',
//               value: 'Wi-Fi',
//             ),
//             _buildNetworkInfoCard(
//               icon: Icons.router,
//               label: 'Opérateur',
//               value: 'Mattel',
//             ),
//             _buildNetworkInfoCard(
//               icon: Icons.location_on,
//               label: 'Location',
//               value: 'Ain taleh',
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildTestingPage() {
//     return Column(
//       key: const ValueKey('TestingPage'), // Clé pour identifier la page
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Upload et Download Speeds
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildSpeedInfo('Upload', '62.9 Mbps'),
//             _buildSpeedInfo('Download', '48.9 Mbps'),
//           ],
//         ),
//         const SizedBox(height: 20),

//         // Ping, Jitter, et Mbps
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildSpeedInfo('Ping', '63 ms'),
//             _buildSpeedInfo('Jitter', '1.5 ms'),
//             _buildSpeedInfo('Mbps', '62.9'),
//           ],
//         ),
//         const SizedBox(height: 30),

//         // Indicateur circulaire
//         Stack(
//           alignment: Alignment.center,
//           children: [
//             Container(
//               width: 200,
//               height: 200,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.grey[200],
//               ),
//               child: Center(
//                 child: Text(
//                   'Download\n143.58 Mbps',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 30),

//         // Bouton Stop Test
//         ElevatedButton(
//           onPressed: () {
//             setState(() {
//               isTesting = false;
//             });
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.red,
//             padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12.0),
//             ),
//           ),
//           child: const Text(
//             'STOP TEST',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildNetworkInfoCard(
//       {required IconData icon, required String label, required String value}) {
//     return Column(
//       children: [
//         Icon(icon, size: 30, color: Colors.black),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: const TextStyle(fontSize: 14, color: Colors.grey),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSpeedInfo(String label, String value) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//       ],
//     );
//   }
// }
