import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikpm_sidoarjo/controllers/admin/kritik_controller.dart';
import 'package:ikpm_sidoarjo/models/kritik_model.dart';
import 'package:ikpm_sidoarjo/admin/layouts/sidebar.dart';

class KritikPageAdmin extends StatefulWidget {
  const KritikPageAdmin({Key? key}) : super(key: key);

  @override
  _KritikPageAdminState createState() => _KritikPageAdminState();
}

class _KritikPageAdminState extends State<KritikPageAdmin> {
  final KritikController _kritikController = KritikController();
  List<KritikModel> _kritikList = [];
  List<KritikModel> _filteredKritikList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndSetKritik();
  }

  Future<void> _fetchAndSetKritik() async {
    try {
      final kritik = await _kritikController.getAllKritik();
      setState(() {
        _kritikList = kritik;
        _filteredKritikList = List.from(kritik);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load kritik: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daftar Kritik',
                    style: GoogleFonts.lato(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: (query) => setState(() {
                      _filteredKritikList = _kritikController.searchKritik(
                          query, _kritikList);
                    }),
                    decoration: const InputDecoration(
                      labelText: 'Cari Kritik',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _filteredKritikList.isEmpty
                            ? const Center(child: Text('Belum ada kritik'))
                            : ListView.builder(
                                itemCount: _filteredKritikList.length,
                                itemBuilder: (context, index) {
                                  final kritik = _filteredKritikList[index];
                                  return Card(
                                    elevation: 3,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        kritik.nama,
                                        style: GoogleFonts.lato(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            kritik.kritik,
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Stambuk: ${kritik.stambuk}',
                                            style: GoogleFonts.lato(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Dikirim pada: ${kritik.createdAt}',
                                            style: GoogleFonts.lato(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () async {
                                          final confirmDelete =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                  'Konfirmasi Hapus'),
                                              content: const Text(
                                                  'Anda yakin ingin menghapus kritik ini?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text('Batal'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: const Text('Hapus'),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirmDelete == true) {
                                            try {
                                              await _kritikController
                                                  .deleteKritik(kritik.id);
                                              setState(() {
                                                _kritikList.remove(kritik);
                                                _filteredKritikList
                                                    .remove(kritik);
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Kritik berhasil dihapus'),
                                                ),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Error deleting kritik: $e')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}