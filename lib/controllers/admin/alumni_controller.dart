import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ikpm_sidoarjo/models/alumni_model.dart';

class AlumniController {
  final String baseUrl = 'https://backend-ikpmsidoarjo.vercel.app';

  // Fetch all alumni
  Future<List<AlumniModel>> fetchAlumni() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/alumni'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => AlumniModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch alumni: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching alumni: $e');
    }
  }

  // Fetch alumni detail by stambuk
  Future<AlumniModel> fetchAlumniDetail(String stambuk) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/alumni/$stambuk'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return AlumniModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch alumni detail: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching alumni detail: $e');
    }
  }

  // Update alumni profile
  Future<void> updateAlumni(String stambuk, Map<String, dynamic> updateData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/alumni/$stambuk'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update alumni profile: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error updating alumni profile: $e');
    }
  }

  // Update hidden fields for alumni
  Future<List<String>> updateHiddenFields(String stambuk, List<String> hiddenFields) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/hidden_fields/$stambuk'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'hidden_fields': hiddenFields}),
      );

      if (response.statusCode == 200) {
        return List<String>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to update hidden fields: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error updating hidden fields: $e');
    }
  }
}