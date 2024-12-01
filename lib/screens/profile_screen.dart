// import 'package:flutter/material.dart';

// class ProfileScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text('Profile', style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'myname@email.com',
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Subscription active until May 15, 2023',
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: FeatureCard(
//                     title: 'Dark Web Monitor',
//                     subtitle: 'No leaks',
//                     iconData: Icons.security,
//                     color: Colors.green,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: FeatureCard(
//                     title: 'Security Score',
//                     subtitle: '40%',
//                     iconData: Icons.shield,
//                     color: Colors.blue,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Other',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             ServiceCard(
//               title: 'NordPass',
//               subtitle: 'Secure password manager',
//               iconData: Icons.vpn_key,
//               color: Colors.teal,
//               onTap: () {
//                 _handleServiceTap(context, 'NordPass');
//               },
//             ),
//             ServiceCard(
//               title: 'NordLocker',
//               subtitle: 'Encrypted cloud storage',
//               iconData: Icons.cloud,
//               color: Colors.deepPurple,
//               onTap: () {
//                 _handleServiceTap(context, 'NordLocker');
//               },
//             ),
//             ServiceCard(
//               title: 'NordLayer',
//               subtitle: 'Network access security',
//               iconData: Icons.lock,
//               color: Colors.green,
//               onTap: () {
//                 _handleServiceTap(context, 'NordLayer');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _handleServiceTap(BuildContext context, String serviceName) {
//     // Implement your navigation or other action here
//     // For example, navigate to a detailed service screen:
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Tapped on $serviceName')),
//     );
//   }
// }

// class FeatureCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData iconData;
//   final Color color;

//   const FeatureCard({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.iconData,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 6,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(iconData, color: color, size: 40),
//           const SizedBox(height: 10),
//           Text(
//             title,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             subtitle,
//             style: TextStyle(color: color),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ServiceCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData iconData;
//   final Color color;
//   final VoidCallback? onTap; // Parameter for tap action

//   const ServiceCard({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.iconData,
//     required this.color,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 10),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 6,
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Icon(iconData, color: color, size: 40),
//             const SizedBox(width: 16),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(subtitle),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
