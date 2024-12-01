import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchService {
  final String baseUrl;

  SearchService({required this.baseUrl});

  /// Fetch operator performance data based on technology and indicator.
  Future<Map<String, dynamic>> fetchOperatorPerformance({
    required String technology,
    required String indicator,
  }) async {
    final url = Uri.parse('$baseUrl/fetch-operator-performance/');
    final requestBody = {
      'technology': technology,
      'indicator': indicator,
    };

    try {
      print('POST URL: $url');
      print('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch operator performance: ${response.body}');
      }
    } catch (e) {
      print('Error in fetchOperatorPerformance: $e');
      rethrow;
    }
  }
}
