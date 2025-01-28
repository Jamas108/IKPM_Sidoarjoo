import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AlumniController with ChangeNotifier {
  List<dynamic> alumniData = []; // Data asli alumni
  List<dynamic> filteredAlumniData = []; // Data alumni setelah difilter
  bool isLoading = true;
  String? selectedTahun; // Status loading
  String? selectedPondok; // Filter berdasarkan asal pondok
  String? selectedKecamatan; // Filter berdasarkan kecamatan
  TextEditingController searchController = TextEditingController();

  // Jumlah baris per halaman
  int rowsPerPage = 5;

  // Data detail alumni
  Map<String, dynamic>? detailAlumni;
  List<String> hiddenFields = [];
  bool isDetailLoading = false;

  // Fungsi untuk mengambil data alumni
  Future<void> fetchAlumniData() async {
    try {
      final response = await http
          .get(Uri.parse('https://backend-ikpmsidoarjo.vercel.app/alumni'));
      if (response.statusCode == 200) {
        alumniData = json.decode(response.body);
        filteredAlumniData = alumniData; // Awalnya tampilkan semua data
      } else {
        throw Exception('Failed to load alumni data');
      }
    } catch (error) {
      print('Error fetching alumni data: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi untuk memfilter data berdasarkan input pencarian
  void filterAlumniData() {
    final searchQuery = searchController.text.toLowerCase();

    filteredAlumniData = alumniData.where((alumni) {
      final nama = alumni['nama_alumni']?.toLowerCase() ?? '';
      final stambuk = alumni['stambuk']?.toLowerCase() ?? '';
      final kampus = alumni['kampus_asal']?.toLowerCase() ?? '';
      final kecamatan = alumni['kecamatan']?.toLowerCase() ?? '';
      final tahun = alumni['tahun']?.toLowerCase() ?? '';

      // Cek apakah query pencarian sesuai dengan atribut apa pun
      final matchesSearch = nama.contains(searchQuery) ||
          stambuk.contains(searchQuery) ||
          kampus.contains(searchQuery) ||
          kecamatan.contains(searchQuery);

      // Cek filter tahun, pondok, dan kecamatan
      final matchesTahun =
          selectedTahun == null || alumni['tahun'] == selectedTahun;
      final matchesPondok =
          selectedPondok == null || alumni['kampus_asal'] == selectedPondok;
      final matchesKecamatan =
          selectedKecamatan == null || alumni['kecamatan'] == selectedKecamatan;

      return matchesSearch && matchesTahun && matchesPondok && matchesKecamatan;
    }).toList();

    notifyListeners();
  }

  void resetFilters() {
    selectedTahun = null;
    selectedPondok = null;
    selectedKecamatan = null;
    searchController.clear(); // Mengosongkan input pencarian
    filteredAlumniData = alumniData; // Kembalikan data asli tanpa filter
    notifyListeners();
  }

  // Fungsi untuk mengubah filter pondok
  void setTahunFilter(String? tahun) {
    selectedTahun = tahun;
    filterAlumniData();
  }

  void setPondokFilter(String? pondok) {
    selectedPondok = pondok;
    filterAlumniData();
  }

  void setKecamatanFilter(String? kecamatan) {
    selectedKecamatan = kecamatan;
    filterAlumniData();
  }

  // Fungsi untuk mengubah jumlah baris per halaman
  void setRowsPerPage(int rows) {
    rowsPerPage = rows;
    notifyListeners();
  }

  // Fungsi untuk mengambil detail alumni berdasarkan stambuk
  // Fungsi untuk mengambil detail alumni berdasarkan stambuk
  Future<void> fetchDetailAlumni(String stambuk) async {
    try {
      isDetailLoading = true;
      notifyListeners();

      final response = await http.get(
          Uri.parse('https://backend-ikpmsidoarjo.vercel.app/alumni/$stambuk'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Simpan detail alumni
        detailAlumni = data;

        // Ambil hidden fields jika ada
        hiddenFields = List<String>.from(data['hidden_fields'] ?? []);

        notifyListeners();
      } else {
        throw Exception('Failed to load detail alumni');
      }
    } catch (error) {
      print('Error fetching detail alumni: $error');
    } finally {
      isDetailLoading = false;
      notifyListeners();
    }
  }

  void resetDetailAlumni() {
    detailAlumni = null;
    isDetailLoading = false;
    notifyListeners();
  }

  // Getter untuk pilihan tahun (diurutkan dari terkecil ke terbesar)
  List<String> get sortedTahunList {
    return alumniData
        .map((e) => e['tahun']?.toString() ?? '') // Konversi ke String
        .where((tahun) => tahun.isNotEmpty) // Hapus entri kosong
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b)); // Urutkan dari terkecil ke terbesar
  }

// Getter untuk pilihan kampus asal (diurutkan alfabetis)
  List<String> get sortedPondokList {
    return alumniData
        .map((e) => e['kampus_asal']?.toString() ?? '')
        .where((pondok) => pondok.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b)); // Urutkan alfabetis
  }

// Getter untuk pilihan kecamatan (diurutkan alfabetis)
  List<String> get sortedKecamatanList {
    return alumniData
        .map((e) => e['kecamatan']?.toString() ?? '')
        .where((kecamatan) => kecamatan.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b)); // Urutkan alfabetis
  }
}
