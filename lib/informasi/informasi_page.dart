import 'package:flutter/foundation.dart'; // Untuk deteksi Web
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/informasi_controller.dart';
import '../models/informasi_model.dart';
import '../layouts/navbar_layout.dart'; // Navbar untuk Web
import '../layouts/bottom_bar.dart'; // BottomBar untuk Android

class InformasiPage extends StatefulWidget {
  const InformasiPage({super.key});

  @override
  _InformasiPageState createState() => _InformasiPageState();
}

class _InformasiPageState extends State<InformasiPage> {
  final InformasiController _informasiController = InformasiController();
  List<InformasiModel> _informasiList = [];
  List<InformasiModel> _filteredInformasiList = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 2; // Indeks untuk navigasi BottomBar (Informasi)

  @override
  void initState() {
    super.initState();
    _fetchInformasi();
  }

  Future<void> _fetchInformasi() async {
    try {
      final informasiList = await _informasiController.fetchInformasi();
      setState(() {
        _informasiList = informasiList;
        _filteredInformasiList = informasiList;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching informasi: $error');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load informasi')),
      );
    }
  }

  void _onSearch(String query) {
    setState(() {
      _filteredInformasiList =
          _informasiController.filterInformasi(_informasiList, query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb; // Deteksi platform Web atau Android
    final bool isMobile = !isWeb && (MediaQuery.of(context).size.width < 600); // Menentukan apakah platform mobile
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: isWeb
          ? const Navbar() // Navbar untuk Web
          : AppBar(
              title: const Text(
                "Daftar Informasi",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20, // Ukuran font lebih besar
                  fontWeight: FontWeight.w600, // Berat font medium untuk kesan elegan
                  fontFamily: 'Roboto', // Gunakan font elegan, contoh: Roboto
                  letterSpacing: 1.2, // Memberikan spasi antar huruf
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 23, 114, 110),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Banner - hanya muncul di Web
                  if (isWeb)
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 2,
                      child: Image.asset(
                        'assets/bannerinformasi.png',
                        fit: BoxFit.cover,
                      ),
                    ),

                  // Form Search
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearch,
                      decoration: InputDecoration(
                        labelText: 'Cari Informasi',
                        hintText: 'Masukkan nama informasi',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pesan jika tidak ada hasil pencarian
                  if (_filteredInformasiList.isEmpty)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: const Text(
                            'Informasi tidak ditemukan.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        // Spacer untuk mendorong footer ke bawah
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3, // 30% tinggi layar
                        ),
                      ],
                    ),

                  // GridView Responsif
                  if (_filteredInformasiList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        alignment: WrapAlignment.start,
                        children: _filteredInformasiList.map((informasi) {
                          return _buildInformasiCard(informasi, width);
                        }).toList(),
                      ),
                    ),

                  // Footer (hanya tampil jika bukan di mobile)
                  // if (!isMobile)
                  //   const SizedBox(height: 16),
                  //   Container(
                  //     width: double.infinity,
                  //     color: const Color(0xFF2C7566),
                  //     padding: const EdgeInsets.symmetric(vertical: 20.0),
                  //     child: const Center(
                  //       child: Text(
                  //         "© 2025 IKPM Sidoarjo. All Rights Reserved.",
                  //         style: TextStyle(color: Colors.white, fontSize: 14),
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),
      bottomNavigationBar: isWeb
          ? null
          : BottomBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
    );
  }

  Widget _buildInformasiCard(InformasiModel informasi, double width) {
    double cardWidth;
    if (width > 1200) {
      cardWidth = width / 4 - 32; // 4 kolom
    } else if (width > 900) {
      cardWidth = width / 3 - 32; // 3 kolom
    } else if (width > 600) {
      cardWidth = width / 2 - 32; // 2 kolom
    } else {
      cardWidth = width - 32; // 1 kolom
    }

    return GestureDetector(
      onTap: () {
        context.go(
          '/informasi/detail/${informasi.id}',
          extra: {'informasi': informasi}, // Kirim data dengan extra
        );
      },
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 10.0), // Padding di atas poster
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: Image.network(
                    informasi.image,
                    fit: BoxFit.contain, // Agar gambar ditampilkan dalam ukuran asli tanpa dipotong
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'No Image',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    informasi.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tanggal: ${informasi.date}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity, // Lebar tombol memenuhi kartu
                    child: ElevatedButton(
                      onPressed: () {
                        context.go(
                          '/informasi/detail/${informasi.id}',
                          extra: {'informasi': informasi},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 23, 114, 110),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Lebih Lengkap',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}