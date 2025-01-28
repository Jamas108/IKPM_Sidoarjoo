import 'package:flutter/foundation.dart'; // Untuk deteksi Web
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../controllers/kegiatan_controller.dart';
import 'package:go_router/go_router.dart';
import '../models/event_model.dart';
import '../layouts/navbar_layout.dart';

class RiwayatEventPage extends StatefulWidget {
  const RiwayatEventPage({super.key});

  @override
  State<RiwayatEventPage> createState() => _RiwayatEventPageState();
}

class _RiwayatEventPageState extends State<RiwayatEventPage> {
  final EventController _eventController = EventController();
  late Future<List<EventModel>> _futureKegiatans;

  @override
  void initState() {
    super.initState();

    // Ambil userId dari AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userStambuk;

    // Pastikan userId tidak null
    if (userId != null) {
      _futureKegiatans = _eventController.fetchRiwayatKegiatan(userId);
    } else {
      _futureKegiatans = Future.error('User ID tidak ditemukan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb; // Deteksi platform Web atau Mobile
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: isWeb
          ? const Navbar() // AppBar untuk Web
          : AppBar(
              title: const Text(
                'Riwayat Kegiatan',
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
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
              automaticallyImplyLeading: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  GoRouter.of(context).go('/profil');
                },
              ),
            ),
      body: FutureBuilder<List<EventModel>>(
        future: _futureKegiatans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada event yang diikuti',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }

          final events = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tampilkan banner hanya di platform Web
                if (isWeb)
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 2,
                    child: Image.asset(
                      'assets/bannerriwayat.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16), // Jarak antara banner dan konten

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${authProvider.userNama ?? "Pengguna"}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Berikut adalah daftar event yang Anda ikuti:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap:
                            true, // Pastikan ListView tidak memenuhi layar
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              leading: event.poster.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        event.poster,
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.broken_image,
                                              size: 50, color: Colors.grey);
                                        },
                                      ),
                                    )
                                  : const Icon(Icons.event),
                              title: Text(event.name),
                              subtitle: Text(
                                'Tanggal: ${event.date}, Jam: ${event.time}\nLokasi: ${event.location}',
                              ),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Klik pada ${event.name}')),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Footer hanya ditampilkan di platform Web
                if (isWeb) const SizedBox(height: 16),
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
          );
        },
      ),
    );
  }
}
