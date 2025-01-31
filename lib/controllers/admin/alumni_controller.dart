import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ikpm_sidoarjo/models/alumni_model.dart';

class AlumniController {
  final String baseUrl = 'https://backend-ikpmsidoarjo.vercel.app';

  // **Daftar Kampus Manual untuk Filter**
 

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
 // **Search & Filter Alumni Data**
  Future<List<AlumniModel>> searchAlumni({
    String? searchQuery,
    String? selectedYear,
    String? selectedCampus,
    String? selectedKecamatan,
  }) async {
    try {
      final alumni = await fetchAlumni();

      return alumni.where((alumni) {
        final nama = alumni.namaAlumni?.toLowerCase() ?? '';
        final stambuk = alumni.stambuk?.toLowerCase() ?? '';
        final kampus = alumni.kampusAsal?.toLowerCase() ?? '';
        final kecamatan = alumni.kecamatan?.toLowerCase() ?? '';
        final tahun = alumni.tahun?.toLowerCase() ?? '';

        // **Pencarian Fleksibel**
        final matchesSearch = searchQuery == null || searchQuery.isEmpty ||
            nama.contains(searchQuery.toLowerCase()) ||
            stambuk.contains(searchQuery.toLowerCase()) ||
            kampus.contains(searchQuery.toLowerCase()) ||
            kecamatan.contains(searchQuery.toLowerCase());

        // **Filter Tahun (Harus Sama Persis)**
        final matchesYear = selectedYear == null || tahun == selectedYear.toLowerCase();

        // **Pencocokan Sebagian untuk Filter Kampus**
        final matchesCampus = selectedCampus == null || kampus.contains(selectedCampus.toLowerCase());

        // **Pencocokan Sebagian untuk Filter Kecamatan**
        final matchesKecamatan = selectedKecamatan == null || kecamatan.contains(selectedKecamatan.toLowerCase());

        return matchesSearch && matchesYear && matchesCampus && matchesKecamatan;
      }).toList();
    } catch (e) {
      throw Exception('Error searching alumni: $e');
    }
  }

  // **Getter untuk Filter Tahun**
  List<String> getSortedYearList(List<AlumniModel> alumniList) {
    return alumniList
        .map((e) => e.tahun ?? '')
        .where((tahun) => tahun.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));
  }

  // **Getter untuk Filter Kampus (Gunakan Daftar Manual)**
  List<String> getSortedPondokList() {
    return [
      'PMDG Putra Kampus 1', 'PMDG Putra Kampus 2', 'PMDG Putra Kampus 3', 
      'PMDG Putra Kampus 4', 'PMDG Putra Kampus 5', 'PMDG Putra Kampus 6', 
      'PMDG Putra Kampus 7', 'PMDG Putra Kampus 8', 'PMDG Putra Kampus 9', 
      'PMDG Putra Kampus 10', 'PMDG Putra Kampus 11', 'PMDG Putra Kampus 12', 
      'PMDG Putri Kampus 1', 'PMDG Putri Kampus 2', 'PMDG Putri Kampus 3', 
      'PMDG Putri Kampus 4', 'PMDG Putri Kampus 5', 'PMDG Putri Kampus 6', 
      'PMDG Putri Kampus 7', 'PMDG Putri Kampus 8'
    ];
  }

  // **Getter untuk Filter Kecamatan**
  List<String> getSortedKecamatanList(List<AlumniModel> alumniList) {
    return alumniList
        .map((e) => e.kecamatan ?? '')
        .where((kecamatan) => kecamatan.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));
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
