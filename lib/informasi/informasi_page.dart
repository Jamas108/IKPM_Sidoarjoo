import 'package:flutter/foundation.dart'; // Untuk mendeteksi Web
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

    return Scaffold(
      appBar: isWeb
          ? const Navbar() // Navbar untuk Web
          : AppBar(
              title: const Text("Informasi Page"),
              backgroundColor: const Color.fromARGB(255, 23, 114, 110),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Banner hanya untuk Web
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
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
                  // Daftar Informasi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: isWeb
                        ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 12.0,
                              mainAxisSpacing: 12.0,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: _filteredInformasiList.length,
                            itemBuilder: (context, index) {
                              final informasi = _filteredInformasiList[index];
                              return _buildInformasiCard(informasi, isWeb);
                            },
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredInformasiList.length,
                            itemBuilder: (context, index) {
                              final informasi = _filteredInformasiList[index];
                              return _buildInformasiCard(informasi, isWeb);
                            },
                          ),
                  ),
                  // Tambahkan Padding antara daftar informasi dan footer
                  const SizedBox(height: 16),
                  // Footer
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF2C7566),
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: const Center(
                      child: Text(
                        "© 2025 IKPM Sidoarjo. All Rights Reserved.",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
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

  Widget _buildInformasiCard(InformasiModel informasi, bool isWeb) {
    return GestureDetector(
      onTap: () {
        context.go(
          '/informasi/detail/${informasi.id}',
          extra: {'informasi': informasi}, // Kirim data dengan extra
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                height: 140,
                width: double.infinity,
                child: Image.network(
                  informasi.image,
                  fit: BoxFit.contain,
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
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                informasi.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Tanggal: ${informasi.date}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 23, 114, 110),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  context.go(
                    '/informasi/detail/${informasi.id}',
                    extra: {'informasi': informasi}, // Kirim data dengan extra
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 23, 114, 110),
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
    );
  }
}