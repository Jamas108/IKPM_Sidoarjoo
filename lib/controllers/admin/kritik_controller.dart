import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ikpm_sidoarjo/models/kritik_model.dart';

class KritikController {
  final String baseUrl = 'https://backend-ikpmsidoarjo.vercel.app';

  Future<List<KritikModel>> getAllKritik() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/kritik'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => KritikModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch kritik: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching kritik: $e');
    }
  }

  Future<void> deleteKritik(String kritikId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/kritik/$kritikId'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete kritik: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error deleting kritik: $e');
    }
  }

  List<KritikModel> searchKritik(String query, List<KritikModel> kritikList) {
    return kritikList
        .where((kritik) =>
            kritik.nama.toLowerCase().contains(query.toLowerCase()) ||
            kritik.kritik.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}