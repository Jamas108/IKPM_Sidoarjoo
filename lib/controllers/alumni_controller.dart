import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AlumniController with ChangeNotifier {
  List<dynamic> alumniData = []; // Data asli alumni
  List<dynamic> filteredAlumniData = []; // Data alumni setelah difilter
  bool isLoading = true;
  String? selectedTahun; // Filter berdasarkan tahun
  String? selectedPondok; // Filter berdasarkan asal pondok
  String? selectedKecamatan; // Filter berdasarkan kecamatan
  TextEditingController searchController = TextEditingController();

  // Jumlah baris per halaman
  int rowsPerPage = 5;

  // Data detail alumni
  Map<String, dynamic>? detailAlumni;
  List<String> hiddenFields = [];
  bool isDetailLoading = false;

  // **Daftar Kampus Manual untuk Filter**
  final List<String> manualPondokList = [
    'PMDG Putra Kampus 1', 'PMDG Putra Kampus 2', 'PMDG Putra Kampus 3', 
    'PMDG Putra Kampus 4', 'PMDG Putra Kampus 5', 'PMDG Putra Kampus 6', 
    'PMDG Putra Kampus 7', 'PMDG Putra Kampus 8', 'PMDG Putra Kampus 9', 
    'PMDG Putra Kampus 10', 'PMDG Putra Kampus 11', 'PMDG Putra Kampus 12', 
    'PMDG Putri Kampus 1', 'PMDG Putri Kampus 2', 'PMDG Putri Kampus 3', 
    'PMDG Putri Kampus 4', 'PMDG Putri Kampus 5', 'PMDG Putri Kampus 6', 
    'PMDG Putri Kampus 7', 'PMDG Putri Kampus 8'
  ];

  // **Fetch Data Alumni dari API**
  Future<void> fetchAlumniData() async {
    try {
      final response = await http.get(Uri.parse('https://backend-ikpmsidoarjo.vercel.app/alumni'));
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

  // **Filter Alumni Data**
  void filterAlumniData() {
    final searchQuery = searchController.text.toLowerCase();

    filteredAlumniData = alumniData.where((alumni) {
      final nama = alumni['nama_alumni']?.toLowerCase() ?? '';
      final stambuk = alumni['stambuk']?.toLowerCase() ?? '';
      final kampus = alumni['kampus_asal']?.toLowerCase() ?? '';
      final kecamatan = alumni['kecamatan']?.toLowerCase() ?? '';
      final tahun = alumni['tahun']?.toLowerCase() ?? '';

      // **Pencocokan Sebagian untuk Filter Kampus**
      final matchesPondok = selectedPondok == null || kampus.contains(selectedPondok!.toLowerCase());

      // **Pencocokan Sebagian untuk Filter Kecamatan**
      final matchesKecamatan = selectedKecamatan == null || kecamatan.contains(selectedKecamatan!.toLowerCase());

      // **Pencarian Fleksibel**
      final matchesSearch = nama.contains(searchQuery) || 
                            stambuk.contains(searchQuery) || 
                            kampus.contains(searchQuery) || 
                            kecamatan.contains(searchQuery);

      // **Filter Tahun (Harus Sama Persis)**
      final matchesTahun = selectedTahun == null || alumni['tahun'] == selectedTahun;

      return matchesSearch && matchesTahun && matchesPondok && matchesKecamatan;
    }).toList();

    notifyListeners();
  }

  // **Reset Semua Filter**
  void resetFilters() {
    selectedTahun = null;
    selectedPondok = null;
    selectedKecamatan = null;
    searchController.clear(); // Mengosongkan input pencarian
    filteredAlumniData = alumniData; // Kembalikan data asli tanpa filter
    notifyListeners();
  }

  // **Set Filter dan Trigger Penyaringan**
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

  // **Set Jumlah Baris Per Halaman**
  void setRowsPerPage(int rows) {
    rowsPerPage = rows;
    notifyListeners();
  }

  // **Ambil Detail Alumni berdasarkan Stambuk**
  Future<void> fetchDetailAlumni(String stambuk) async {
    try {
      isDetailLoading = true;
      notifyListeners();

      final response = await http.get(Uri.parse('https://backend-ikpmsidoarjo.vercel.app/alumni/$stambuk'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        detailAlumni = data;
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

  // **Reset Detail Alumni**
  void resetDetailAlumni() {
    detailAlumni = null;
    isDetailLoading = false;
    notifyListeners();
  }

  // **Getter untuk Filter Tahun**
  List<String> get sortedTahunList {
    return alumniData
        .map((e) => e['tahun']?.toString() ?? '') // Konversi ke String
        .where((tahun) => tahun.isNotEmpty) // Hapus entri kosong
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b)); // Urutkan dari terkecil ke terbesar
  }

  // **Getter untuk Filter Kampus (Gunakan Daftar Manual)**
  List<String> get sortedPondokList {
    return manualPondokList;
  }

  // **Getter untuk Filter Kecamatan**
  List<String> get sortedKecamatanList {
    return alumniData
        .map((e) => e['kecamatan']?.toString() ?? '')
        .where((kecamatan) => kecamatan.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b)); // Urutkan alfabetis
  }
}