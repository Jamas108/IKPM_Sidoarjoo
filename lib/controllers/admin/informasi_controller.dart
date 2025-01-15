import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:ikpm_sidoarjo/models/informasi_model.dart';

class InformasiController {
  final String baseUrl = 'https://backend-ikpmsidoarjo.vercel.app';

  // Fetch all berita
  Future<List<InformasiModel>> fetchInformasi() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/informasis'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => InformasiModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch berita: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching berita: $e');
    }
  }

  // Filter berita by query
  List<InformasiModel> filterInformasi(
      List<InformasiModel> informasiList, String query) {
    if (query.isEmpty) {
      return informasiList;
    }
    return informasiList
        .where(
            (informasi) => informasi.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Delete berita by ID and refresh list
  Future<List<InformasiModel>> deleteInformasiAndRefresh(
      String beritaId, List<InformasiModel> informasiList) async {
    try {
      final response =
          await http.delete(Uri.parse('$baseUrl/informasis/$beritaId'));

      if (response.statusCode == 200) {
        return informasiList
            .where((informasi) => informasi.id != beritaId)
            .toList();
      } else {
        throw Exception('Failed to delete berita: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error deleting berita: $e');
    }
  }

  // Add new berita
  Future<void> addInformasi({
    required String title,
    required String date,
    required String time,
    required String description,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/informasis'),
      );

      request.fields['name'] = title; // Ubah sesuai backend
      request.fields['date'] = date;
      request.fields['time'] = time;
      request.fields['description'] = description;

      if (imageBytes != null && imageName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: imageName,
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode != 201) {
        final responseData = await response.stream.bytesToString();
        throw Exception(
            'Failed to add informasi: ${response.reasonPhrase} - $responseData');
      }
    } catch (e) {
      throw Exception('Error adding informasi: $e');
    }
  }

  // Update berita by ID
  Future<void> updateInformasi({
    required String id,
    required String name,
    required String date,
    required String time,
    required String description,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/informasis/$id'),
      );

      request.fields['name'] = name;
      request.fields['date'] = date;
      request.fields['time'] = time;
      request.fields['description'] = description;

      if (imageBytes != null && imageName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: imageName,
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('Failed to update berita: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error updating berita: $e');
    }
  }

  // Get berita by ID
  Future<InformasiModel> getBeritaById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/informasis/$id'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return InformasiModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch berita by ID: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching berita by ID: $e');
    }
  }
}
