import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardController {
  // API URLs
  final String alumniUrl = 'https://backend-ikpmsidoarjo.vercel.app/alumni';
  final String kegiatanUrl = 'https://backend-ikpmsidoarjo.vercel.app/kegiatans';
  final String informasiUrl = 'https://backend-ikpmsidoarjo.vercel.app/informasis';
  final String kritikUrl = 'https://backend-ikpmsidoarjo.vercel.app/kritik';

  // Fungsi untuk mengambil data dari API dan menghitung jumlah
  Future<Map<String, int>> getDashboardData() async {
    try {
      // Ambil data dari API
      final alumniResponse = await http.get(Uri.parse(alumniUrl));
      final kegiatanResponse = await http.get(Uri.parse(kegiatanUrl));
      final informasiResponse = await http.get(Uri.parse(informasiUrl));
      final kritikResponse = await http.get(Uri.parse(kritikUrl));

      // Periksa apakah request berhasil (status code 200)
      if (alumniResponse.statusCode == 200 &&
          kegiatanResponse.statusCode == 200 &&
          informasiResponse.statusCode == 200 &&
          kritikResponse.statusCode == 200) {
        // Parse JSON dan hitung jumlah data untuk setiap model
        final alumniData = jsonDecode(alumniResponse.body);
        final kegiatanData = jsonDecode(kegiatanResponse.body);
        final informasiData = jsonDecode(informasiResponse.body);
        final kritikData = jsonDecode(kritikResponse.body);

        return {
          'alumni': alumniData.length,
          'kegiatan': kegiatanData.length,
          'informasi': informasiData.length,
          'kritik': kritikData.length,
        };
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}