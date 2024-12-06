import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
                        ? _buildVerticalBarChart()
                        : const Center(
                            child: Text('No data available'),
                          ),
              ),

              // Banner
              const SizedBox(height: 24),
              Center(
                child: Image.asset(
                  'assets/images/Capture.png', // Remplacez par le chemin de votre image
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),

              // Location Section
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Tevrek Zeyna - Soukouk', // Replace with your location
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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

 Widget _buildVerticalBarChart() {
  final operators = _chartData?['group_by_operator']?['buckets'] ?? [];
  final List<BarChartGroupData> barGroups = [];

  // Trouver la valeur maximale pour l'échelle du graphe
  double maxValue = 0.0;

  for (int i = 0; i < operators.length; i++) {
    final operator = operators[i];
    final double averageValue = operator['average_indicator']['value']?.toDouble() ?? 0.0;
    maxValue = max(maxValue, averageValue);

    barGroups.add(
      BarChartGroupData(
        x: i, // Utilise l'index comme valeur de l'axe des X
        barRods: [
          BarChartRodData(
            toY: averageValue, // Valeur de l'indicateur sur l'axe des Y
            color: _getBarColor(i),
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [0],
      ),
    );
  }

  return BarChart(
    BarChartData(
      maxY: maxValue, // Ajuste l'échelle maximale
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final operatorName = operators[group.x.toInt()]['key'];
            return BarTooltipItem(
              '$operatorName\n',
              const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 8,
                color: Colors.white,
              ),
              children: [
                TextSpan(
                  text: '${rod.toY.toStringAsFixed(2)}%',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ],
            );
          },
        ),
      ),
     titlesData: FlTitlesData(
  leftTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 40,
      getTitlesWidget: (double value, TitleMeta meta) {
        return Text(
          '${value.toStringAsFixed(0)}%', // Show percentages
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        );
      },
    ),
  ),
  bottomTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 60, // Space for operator names
      getTitlesWidget: (double value, TitleMeta meta) {
        final index = value.toInt();
        if (index < operators.length) {
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 4.0,
            child: Text(
              operators[index]['key'],
              style: const TextStyle(
                fontSize: 10, // Smaller font size
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return const SizedBox();
      },
    ),
  ),
  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
),
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: false),
      barGroups: barGroups,
      alignment: BarChartAlignment.spaceAround,
      groupsSpace: 16, // Espacement entre les barres
    ),
  );
}

  Color _getBarColor(int index) {
    const List<Color> colors = [
      Color(0xff63C2FF), // Chingutel
      Color(0xff4CBD7F), // Rimatel
      Color(0xffFFB946), // Mauritel
      Color(0xff5085F6), // Mattel
    ];
    return colors[index % colors.length];
  }
}
