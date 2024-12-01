import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const DetailsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(result['date'] ?? 'Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${result['date']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Download Speed: ${result['download']} Mbps',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Signal Strength: ${result['signal']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Technology: ${result['technology']}',
              style: const TextStyle(fontSize: 16),
            ),
            // Add more details here if needed
          ],
        ),
      ),
    );
  }
}
