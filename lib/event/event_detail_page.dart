import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import '../layouts/navbar_layout.dart';

class DetailEvent extends StatelessWidget {
  final EventModel event;

  const DetailEvent({required this.event, Key? key}) : super(key: key);

  // Fungsi untuk mendaftar ke event
  Future<void> _registerForEvent(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Ambil stambuk dari AuthProvider
    String? stambuk = authProvider.userStambuk;

    // Validasi jika user belum login
    if (stambuk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu untuk mendaftar!'),
        ),
      );
      return;
    }

    final eventController = EventController();

    try {
      // Mendaftarkan user ke event melalui controller
      await eventController.registerForEvent(userId: stambuk, kegiatanId: event.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil mendaftar untuk kegiatan!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Anda sudah terdaftar dalam kegiatan ini')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? stambuk = authProvider.userStambuk;
    final bool isWeb = kIsWeb; // Deteksi jika platform adalah Web

    return Scaffold(
      appBar: isWeb
          ? const Navbar() // Navbar untuk Web
          : AppBar(
              title: const Text(
                'Detail Event',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: true,
            ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Poster gambar ukuran penuh dengan skala kecil
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                event.poster, // URL poster dari EventModel
                width: MediaQuery.of(context).size.width * 0.9, // 90% lebar layar
                height: MediaQuery.of(context).size.height * 0.5, // 50% tinggi layar
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text(
                    'No Image Available',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nama event
            Center(
              child: Text(
                event.name, // Nama event dari EventModel
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            // Lokasi dan tanggal
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min, // Sesuaikan lebar konten dengan isi
                children: [
                  // Lokasi
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blueGrey),
                      const SizedBox(width: 8),
                      Text(
                        event.location, // Lokasi dari EventModel
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16), // Sedikit jarak antar kolom
                  // Tanggal
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blueGrey),
                      const SizedBox(width: 8),
                      Text(
                        event.date, // Tanggal dari EventModel
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Detail deskripsi dibungkus dengan Card full-width
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Judul "Deskripsi Kegiatan"
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Deskripsi Kegiatan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    // Konten deskripsi
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        event.description, // Deskripsi dari EventModel
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Tombol daftar
            Center(
              child: ElevatedButton(
                onPressed: () => _registerForEvent(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: stambuk != null ? const Color.fromARGB(255, 23, 114, 110) : Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  stambuk != null ? 'Daftar Acara' : 'Login untuk Mendaftar',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
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
    );
  }
}