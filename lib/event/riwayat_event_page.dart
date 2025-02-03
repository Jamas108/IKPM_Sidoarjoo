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
  List<EventModel> _filteredEvents = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userStambuk;

    if (userId != null) {
      _futureKegiatans = _eventController.fetchRiwayatKegiatan(userId);
      _futureKegiatans.then((data) {
        setState(() {
          _filteredEvents = data;
        });
      });
    } else {
      _futureKegiatans = Future.error('User ID tidak ditemukan');
    }
  }

  void _searchEvent(String query) {
    setState(() {
      _filteredEvents = _eventController.filterKegiatan(query);
    });
  }

  Future<void> _deleteEvent(String eventId) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete) {
      await _eventController.deleteEvent(eventId);
      setState(() {
        _filteredEvents.removeWhere((event) => event.id == eventId);
      });
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Konfirmasi Hapus"),
            content: const Text("Apakah Anda yakin ingin menghapus kegiatan ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Hapus", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: isWeb
          ? const Navbar()
          : AppBar(
              title: const Text(
                'Riwayat Kegiatan',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              backgroundColor: const Color.fromARGB(255, 23, 114, 110),
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
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

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWeb)
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 2,
                    child: Image.asset(
                      'assets/bannerriwayat.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),

                // Input Pencarian
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Cari Kegiatan',
                      hintText: 'Masukkan nama kegiatan...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: _searchEvent,
                  ),
                ),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _filteredEvents.isEmpty
                      ? const Center(
                          child: Text(
                            "Tidak ada kegiatan yang sesuai.",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = _filteredEvents[index];
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
                                          errorBuilder: (context, error, stackTrace) {
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
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteEvent(event.id),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                if (isWeb) const SizedBox(height: 16),
                // if (isWeb)
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
          );
        },
      ),
    );
  }
}