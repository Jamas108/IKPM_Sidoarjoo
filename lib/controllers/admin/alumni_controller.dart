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

  // AlumniController.dart
  Future<List<AlumniModel>> searchAlumni({
    String? searchQuery,
    String? selectedYear,
    String? selectedCampus,
    String? selectedKecamatan,
  }) async {
    try {
      final alumni = await fetchAlumni();

      return alumni.where((alumni) {
        final matchesYear =
            selectedYear == null || alumni.tahun == selectedYear;
        final matchesCampus =
            selectedCampus == null || alumni.kampusAsal == selectedCampus;
        final matchesKecamatan =
            selectedKecamatan == null || alumni.kecamatan == selectedKecamatan;
        final matchesSearch = alumni.namaAlumni
                ?.toLowerCase()
                .contains(searchQuery?.toLowerCase() ?? '') ??
            false;

        return matchesYear &&
            matchesCampus &&
            matchesKecamatan &&
            matchesSearch;
      }).toList();
    } catch (e) {
      throw Exception('Error searching alumni: $e');
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
        throw Exception(
            'Failed to fetch alumni detail: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching alumni detail: $e');
    }
  }

  // AlumniController.dart
  Future<bool> createAlumni(Map<String, dynamic> alumniData) async {
    final String apiUrl = '$baseUrl/alumni';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(alumniData),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
            'Failed to create alumni: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating alumni: $e');
    }
  }

  Future<Map<String, dynamic>> loadAlumniById(String stambuk) async {
    final String apiUrl = '$baseUrl/alumni/$stambuk';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load alumni data: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error loading alumni data: $e');
    }
  }

  // Update alumni profile
  Future<void> updateAlumni(
      String stambuk, Map<String, dynamic> updateData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/alumni/$stambuk'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateData),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update alumni profile: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error updating alumni profile: $e');
    }
  }

  Future<void> deleteAlumni(String stambuk) async {
    final String url = '$baseUrl/admin/alumni/$stambuk';
    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete alumni: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting alumni: $e');
    }
  }

  Future<String> fetchCurrentPassword(String stambuk) async {
    final String url = '$baseUrl/admin/alumni/$stambuk';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['password'] ?? '';
      } else {
        throw Exception('Failed to fetch current password: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching current password: $e');
    }
  }

  Future<void> updatePassword(String stambuk, String newPassword) async {
    final String url = '$baseUrl/admin/alumni/$stambuk';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'password': newPassword}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update password: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating password: $e');
    }
  }

  // Update hidden fields for alumni
  Future<List<String>> updateHiddenFields(
      String stambuk, List<String> hiddenFields) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/hidden_fields/$stambuk'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'hidden_fields': hiddenFields}),
      );

      if (response.statusCode == 200) {
        return List<String>.from(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to update hidden fields: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error updating hidden fields: $e');
    }
  }

  
  
}
