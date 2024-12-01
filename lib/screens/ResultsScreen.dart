import 'package:flutter/material.dart';
import 'package:internet/services/network_provider.dart';
import 'package:provider/provider.dart';

class ResultsScreen extends StatelessWidget {
  final List<dynamic> results;

  ResultsScreen({required this.results});

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Results Summary
            Text(
              'Found ${results.length} results',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Results List
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  var item = results[index]['_source'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(item),
                            const Divider(),
                            _buildGroupedInfo('Performance Metrics', [
                              _buildInfoRow('Download Speed', '${item['downloadSpeed']} Mbps', Icons.download),
                              _buildInfoRow('Upload Speed', '${item['uploadSpeed']} Mbps', Icons.upload),
                              _buildInfoRow('Ping', '${item['ping']} ms', Icons.speed),
                              _buildInfoRow('Jitter', '${item['jitter']} ms', Icons.sync_problem),
                              _buildInfoRow('Packet Loss', '${item['packetLoss']}', Icons.error_outline),
                            ]),
                            const SizedBox(height: 8),
                            _buildGroupedInfo('Location Information', [
                              _buildInfoRow('Coordinates', '${item['location']}', Icons.location_on),
                              _buildInfoRow('User Location', '${networkProvider.location}', Icons.person_pin_circle),
                              _buildInfoRow('Server Location', '${item['server_city']}, ${item['server_country']}', Icons.cloud),
                            ]),
                            const SizedBox(height: 8),
                            _buildGroupedInfo('Device Information', [
                              _buildInfoRow('IP Address', '${item['ip_address']}', Icons.vpn_key),
                              _buildInfoRow('Device', '${item['device']}', Icons.phone_android),
                              _buildInfoRow('Signal Strength', '${item['signalStrengthValue']}', Icons.signal_cellular_4_bar),
                            ]),
                            const SizedBox(height: 10),
                            Text(
                              'Comments: ${item['comments'] ?? 'No Comments'}',
                              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          item['operator'] ?? 'No Operator',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Icon(
          Icons.network_check,
          color: Colors.teal,
          size: 30,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedInfo(String title, List<Widget> infoRows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        ...infoRows,
      ],
    );
  }
}
