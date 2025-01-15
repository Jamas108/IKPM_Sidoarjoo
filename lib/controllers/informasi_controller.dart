import 'dart:convert';
import 'package:flutter/foundation.dart'; // Untuk deteksi platform
import 'package:http/http.dart' as http;
import '../models/informasi_model.dart';

class InformasiController {
  late final String apiUrl;

  InformasiController() {
    if (kIsWeb) {
      // URL untuk Web
      apiUrl = 'https://backend-ikpmsidoarjo.vercel.app/informasis';
    } else {
      // URL untuk Android Emulator
      apiUrl = 'https://backend-ikpmsidoarjo.vercel.app/informasis';
    }
  }

  // Fetch data informasi dari API
  Future<List<InformasiModel>> fetchInformasi() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => InformasiModel.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load information');
      }
    } catch (error) {
      throw Exception('Error fetching information: $error');
    }
  }

  // Filter informasi berdasarkan query
  List<InformasiModel>  filterInformasi(
      List<InformasiModel> informasiList, String query) {
    return informasiList
        .where((informasi) =>
            informasi.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
