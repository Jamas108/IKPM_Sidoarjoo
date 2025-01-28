import 'package:flutter/foundation.dart'; // Untuk deteksi Web
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/kegiatan_controller.dart'; // Controller Event
import '../models/event_model.dart'; // Model Event
import '../layouts/navbar_layout.dart'; // Navbar untuk Web
import '../layouts/bottom_bar.dart'; // BottomBar untuk Android

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final EventController _eventController = EventController();
  final TextEditingController _searchController = TextEditingController();
  List<EventModel> _filteredKegiatanList = [];
  bool _isLoading = true;
  int _currentIndex = 1; // Indeks untuk navigasi BottomBar (Kegiatan)

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final events = await _eventController.fetchKegiatan();
      setState(() {
        _filteredKegiatanList = events;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load events')),
      );
    }
  }

  void _onSearch(String query) {
    setState(() {
      _filteredKegiatanList = _eventController.filterKegiatan(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb; // Deteksi platform Web atau Android
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: isWeb
          ? const Navbar() // Navbar untuk Web
          : AppBar(
              title: const Text(
                "Daftar Kegiatan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20, // Ukuran font lebih besar
                  fontWeight:
                      FontWeight.w600, // Berat font medium untuk kesan elegan
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
                  // Tampilkan banner hanya di Web
                  if (isWeb)
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 2,
                      child: Image.asset(
                        'assets/BANNER.png',
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
                        labelText: 'Cari Event',
                        hintText: 'Masukkan nama event',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pesan jika tidak ada hasil pencarian
                  if (_filteredKegiatanList.isEmpty)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: const Text(
                            'Kegiatan tidak ditemukan.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        // Spacer untuk mendorong footer ke bawah
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                      ],
                    ),

                  // GridView Responsif
                  if (_filteredKegiatanList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        alignment: WrapAlignment.start,
                        children: _filteredKegiatanList.map((event) {
                          return _buildKegiatanCard(event, width);
                        }).toList(),
                      ),
                    ),

                  // Footer
                  const SizedBox(height: 16),
                  if (isWeb)
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

  Widget _buildKegiatanCard(EventModel event, double width) {
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
          '/kegiatan/detail/${event.id}',
          extra: {'event': event},
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
                    event.poster,
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
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tanggal: ${event.date}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Badge status
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: _getStatusColor(event.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      event.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go(
                          '/kegiatan/detail/${event.id}',
                          extra: {'event': event},
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

// Fungsi untuk mendapatkan warna status
Color _getStatusColor(String status) {
  switch (status) {
    case 'Berjalan':
      return Colors.green;
    case 'Selesai':
      return Colors.blue;
    case 'Akan Datang':
      return Colors.orange;
    case 'Disembunyikan':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
