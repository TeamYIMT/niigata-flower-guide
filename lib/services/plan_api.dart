import 'dart:convert';
import 'package:http/http.dart' as http;

class PlanRequest {
  final double originLat;
  final double originLng;
  final int durationHours;
  final List<String> keywords;
  final bool includePoi;

  const PlanRequest({
    required this.originLat,
    required this.originLng,
    required this.durationHours,
    required this.keywords,
    required this.includePoi,
  });

  Map<String, dynamic> toJson() => {
        'origin': {'lat': originLat, 'lng': originLng},
        'durationHours': durationHours,
        'keywords': keywords,
        'includePoi': includePoi,
      };
}

class PlanApi {
  final String baseUrl;
  final String path;
  final http.Client _client;

  PlanApi({required this.baseUrl, this.path = '/api/plan', http.Client? client})
      : _client = client ?? http.Client();

  Future<Map<String, dynamic>> createPlan(PlanRequest request) async {
    final uri = Uri.parse('$baseUrl$path');
    final resp = await _client.post(
      uri,
      headers: {'content-type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Plan API error: ${resp.statusCode} ${resp.body}');
  }
}


