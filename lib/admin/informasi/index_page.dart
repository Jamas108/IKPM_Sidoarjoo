import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:ikpm_sidoarjo/controllers/admin/informasi_controller.dart';
import 'package:ikpm_sidoarjo/models/informasi_model.dart';
import 'package:ikpm_sidoarjo/admin/layouts/sidebar.dart';

class InformasiPageAdmin extends StatefulWidget {
  const InformasiPageAdmin({Key? key}) : super(key: key);

  @override
  _InformasiPageAdminState createState() => _InformasiPageAdminState();
}

class _InformasiPageAdminState extends State<InformasiPageAdmin> {
  final InformasiController _informasiController = InformasiController();
  List<InformasiModel> _informasiList = [];
  List<InformasiModel> _filteredInformasiList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInformasi();
  }

  Future<void> _loadInformasi() async {
    try {
      final informasi = await _informasiController.fetchInformasi();
      setState(() {
        _informasiList = informasi;
        _filteredInformasiList = List.from(informasi);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load news: $e')),
      );
    }
  }

  void _onSearch(String query) {
    setState(() {
      _filteredInformasiList =
          _informasiController.filterInformasi(_informasiList, query);
    });
  }

  Future<void> _onDeleteInformasi(String beritaId) async {
    try {
      final updatedList = await _informasiController.deleteInformasiAndRefresh(
        beritaId,
        _informasiList,
      );
      setState(() {
        _informasiList = updatedList;
        _filteredInformasiList = List.from(updatedList);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berita berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error menghapus berita: $e')),
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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kelola Informasi',
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.go('/admin/informasi/create');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 23, 114, 110),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Tambah Informasi',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  TextField(
                    onChanged: _onSearch,
                    decoration: const InputDecoration(
                      labelText: 'Cari Informasi',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Card with Table or Empty Message
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _filteredInformasiList.isEmpty
                            ? Center(
                                child: Text(
                                  'Informasi tidak ditemukan',
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : SizedBox(
                                width: double.infinity,
                                child: DataTable(
                                  columnSpacing: 20,
                                  headingRowHeight: 56,
                                  horizontalMargin: 16,
                                  columns: [
                                    DataColumn(
                                      label: Text(
                                        'No',
                                        style: GoogleFonts.lato(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Judul',
                                        style: GoogleFonts.lato(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Tanggal',
                                        style: GoogleFonts.lato(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Waktu',
                                        style: GoogleFonts.lato(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Aksi',
                                        style: GoogleFonts.lato(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                  rows: _filteredInformasiList
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final berita = entry.value;
                                    return DataRow(cells: [
                                      DataCell(Text('${index + 1}')),
                                      DataCell(Text(berita.name)),
                                      DataCell(Text(berita.date)),
                                      DataCell(Text(berita.time)),
                                      DataCell(Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility,
                                                color: Colors.green),
                                            onPressed: () {
                                              context.go(
                                                  '/admin/informasi/detail/${berita.id}');
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () {
                                              context.go(
                                                  '/admin/informasi/edit/${berita.id}');
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () async {
                                              final confirmDelete =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Konfirmasi Hapus'),
                                                  content: const Text(
                                                      'Anda yakin ingin menghapus informasi ini?'),
                                                  actions: [
                                                    TextButton(
                                                      child:
                                                          const Text('Batal'),
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(false),
                                                    ),
                                                    TextButton(
                                                      child:
                                                          const Text('Hapus'),
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(true),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirmDelete == true) {
                                                await _onDeleteInformasi(
                                                    berita.id);
                                              }
                                            },
                                          ),
                                        ],
                                      )),
                                    ]);
                                  }).toList(),
                                ),
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