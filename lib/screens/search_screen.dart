import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../services/network_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _selectedTechnology = '4G';
  String _selectedIndicator = 'Download';
  Map<String, dynamic>? _chartData;
  bool _isLoading = false;

  final Map<String, Color> _operatorColors = {};
  final List<Color> _colorPalette = [];
  
  final Map<String, String> indicatorMapping = {
    'Download': 'downloadSpeed',
    'Upload': 'uploadSpeed',
    'Signal': 'signalStrengthValue',
  };

  Future<void> _fetchChartData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://104.154.91.24:8000/api/fetch-operator-performance/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'technology': _selectedTechnology,
          'indicator': indicatorMapping[_selectedIndicator]!,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _chartData = data['result'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching chart data: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching chart data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Center(
                child: Text(
                  'BEST OPERATORS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Dropdowns for Technology and Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDropdown(
                    label: 'Technology',
                    value: _selectedTechnology,
                    items: ['4G', 'WiFi', '3G'],
                    onChanged: (value) {
                      setState(() {
                        _selectedTechnology = value!;
                      });
                    },
                  ),
                  _buildDropdown(
                    label: 'Indicator',
                    value: _selectedIndicator,
                    items: ['Download', 'Upload', 'Signal'],
                    onChanged: (value) {
                      setState(() {
                        _selectedIndicator = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Fetch Data Button
              Center(
                child: ElevatedButton(
                  onPressed: _fetchChartData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'SEARCH',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Chart Section
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _chartData != null
                        ? _buildHorizontalBarChart()
                        : const Center(
                            child: Text('No data available'),
                          ),
              ),

              // Banner
              const SizedBox(height: 14),
              Center(
                child: Image.asset(
                  'assets/images/Capture.png', // Remplacez par le chemin de votre image
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),

              // Location Section
              const SizedBox(height: 14),
              _buildNetworkCarde(
                icon: Image.asset(
                  'assets/icons/loc.png',
                  width: 24, // Increased for better visibility
                  height: 24,
                ),
                label: 'Location',
                value: networkProvider.location ?? '', // Provide fallback location
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHorizontalBarChart() {
    final operators = _chartData?['group_by_operator']?['buckets'] ?? [];

    // Calcul du total pour les pourcentages relatifs
    double totalAverage = operators.fold(0.0, (sum, operator) {
      return sum + (operator['average_indicator']['value']?.toDouble() ?? 0.0);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Affichage des graduations de 0% à 100%
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth; // Largeur maximale disponible
            return Padding(
              padding: const EdgeInsets.only(left: 102.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final label = '${index * 25}%';
                  return Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  );
                }),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // Génération dynamique des barres horizontales
        ...operators.map((operator) {
          final averageValue = operator['average_indicator']['value']?.toDouble() ?? 0.0;
          final percentage = totalAverage > 0 ? (averageValue / totalAverage) * 100 : 0.0;
          final normalizedWidth = (percentage / 100).clamp(0.0, 1.0); // Clamp pour éviter les dépassements
          final operatorName = operator['key'];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Nom de l'opérateur
                SizedBox(
                  width: 100,
                  child: Text(
                    operatorName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Barre horizontale avec couleurs
                Expanded(
                  child: Stack(
                    children: [
                      // Fond gris
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      // Portion colorée
                      FractionallySizedBox(
                        widthFactor: normalizedWidth, // Largeur en fonction du pourcentage
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: _getBarColor(operators.indexOf(operator)),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Pourcentage aligné à droite
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getBarColor(operators.indexOf(operator)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
  // Generate a random color as a fallback
  Color _generateRandomColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

Color _getBarColor(String operatorName) {
    if (_operatorColors.containsKey(operatorName)) {
      return _operatorColors[operatorName]!;
    }

    final Color newColor = _colorPalette.length > _operatorColors.length
        ? _colorPalette[_operatorColors.length]
        : _generateRandomColor();

    _operatorColors[operatorName] = newColor;
    return newColor;
  }

}

Widget _buildNetworkCarde({
  required Widget icon,
  required String label,
  required String value,
}) {
  return Center(
    child: Container(
      width: 160,
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
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
      ),
    ),
  );
}
  