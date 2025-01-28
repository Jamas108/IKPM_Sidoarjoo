import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../controllers/profil_controller.dart';
import '../layouts/navbar_layout.dart';
import '../layouts/bottom_bar.dart';

class RiwayatKritikPage extends StatefulWidget {
  const RiwayatKritikPage({Key? key}) : super(key: key);

  @override
  _RiwayatKritikPageState createState() => _RiwayatKritikPageState();
}

class _RiwayatKritikPageState extends State<RiwayatKritikPage> {
  List<Map<String, dynamic>> _kritikList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKritik();
  }

  Future<void> _loadKritik() async {
    try {
      final kritik = await ProfilController().fetchKritikByStambuk(context);
      setState(() {
        _kritikList = kritik;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb; // Deteksi platform Web atau Mobile

    return Scaffold(
      appBar: isWeb
          ? const Navbar()
          : AppBar(
              title: const Text(
                "Riwayat Kritik dan Saran",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  letterSpacing: 1.2,
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 23, 114, 110),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // **Banner hanya untuk mode Web**
          if (isWeb)
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 2, // Ukuran Sama
              child: Image.asset(
                'assets/bannerriwayatsaran.png',
                fit: BoxFit.cover,
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _kritikList.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada kritik dan saran',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: Column(
                            children: _kritikList.map((kritik) {
                              return Card(
                                elevation: 4,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              kritik['kritik'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Tanggal: ${kritik['createdAt'] ?? '-'}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () => _editKritikDialog(
                                                context, kritik),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _confirmDeleteKritik(
                                                    context, kritik['_id']),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
          ),
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
      bottomNavigationBar: isWeb
          ? null
          : BottomBar(
              currentIndex: 0,
              onTap: (index) {
                if (index == 0) {
                  GoRouter.of(context).go('/profile');
                } else if (index == 1) {
                  GoRouter.of(context).go('/alumni');
                }
              },
            ),
    );
  }

  void _editKritikDialog(BuildContext context, Map<String, dynamic> kritik) {
    final TextEditingController _kritikController =
        TextEditingController(text: kritik['kritik']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Kritik'),
          content: TextField(
            controller: _kritikController,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Masukkan kritik yang diperbarui',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedKritik = _kritikController.text.trim();
                if (updatedKritik.isNotEmpty) {
                  await ProfilController()
                      .editKritik(context, kritik['_id'], updatedKritik);
                  Navigator.pop(context);
                  await _loadKritik(); // Refresh data kritik
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kritik tidak boleh kosong')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteKritik(BuildContext context, String kritikId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus kritik ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ProfilController().deleteKritik(context, kritikId);
                Navigator.pop(context);
                await _loadKritik(); // Refresh data kritik
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}