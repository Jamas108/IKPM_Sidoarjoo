import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:ikpm_sidoarjo/admin/informasi/create_page.dart';
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
  int _rowsPerPage = 7; // Number of rows per page for pagination
  int _currentPage = 0; // Current page for pagination

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
    bool? deleteConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Anda yakin ingin menghapus informasi ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed == true) {
      try {
        final updatedList =
            await _informasiController.deleteInformasiAndRefresh(
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
  onPressed: () async {
    // Navigate to AddInformasiPage
    final newInformasi = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddInformasiPage()), // Navigating to the Add Informasi Page
    );

    if (newInformasi != null && newInformasi is InformasiModel) {
      setState(() {
        // Add the new data to the list
        _informasiList.add(newInformasi);
        _filteredInformasiList.add(newInformasi);
      });

      // Reload the list after adding the new information
      await _loadInformasi();
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 23, 114, 110),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                            ? const Center(
                                child: Text(
                                  'Data Kegiatan Tidak Ditemukan.',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.red),
                                ),
                              )
                            : SizedBox(
                                width: double.infinity,
                                child: PaginatedDataTable(
                                  rowsPerPage: _filteredInformasiList.length <
                                          _rowsPerPage
                                      ? _filteredInformasiList.length
                                      : _rowsPerPage,
                                  onPageChanged: (page) {
                                    setState(() {
                                      _currentPage = page;
                                    });
                                  },
                                  columns: const [
                                    DataColumn(
                                        label: Text('No',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Judul',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Tanggal',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Waktu',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Aksi',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                  ],
                                  source: _InformasiDataSource(
                                      _filteredInformasiList,
                                      _onDeleteInformasi,
                                      context,
                                      _loadInformasi,
                                      setState),
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

class _InformasiDataSource extends DataTableSource {
  final List<InformasiModel> _informasi;
  final Function(String) _onDelete;
  final BuildContext _context;
  final Function() _reloadInformasi;
  final Function(VoidCallback) _setState;

  _InformasiDataSource(this._informasi, this._onDelete, this._context,
      this._reloadInformasi, this._setState);

  @override
  DataRow getRow(int index) {
    final informasi = _informasi[index];
    return DataRow(cells: [
      DataCell(Text('${index + 1}')),
      DataCell(Text(informasi.name)),
      DataCell(Text(informasi.date)),
      DataCell(Text(informasi.time)),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.visibility, color: Color.fromARGB(255, 255, 170, 0)),
            onPressed: () {
              _context.go('/admin/informasi/detail/${informasi.id}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () async {
              final updatedInformasi = await _context.push(
                '/admin/informasi/edit/${informasi.id}',
                extra: informasi,
              );

              if (updatedInformasi != null &&
                  updatedInformasi is InformasiModel) {
                _setState(() {
                  // Find and replace the old informasi with the updated one in the list
                  int index =
                      _informasi.indexWhere((i) => i.id == updatedInformasi.id);
                  if (index != -1) {
                    _informasi[index] = updatedInformasi;
                  }
                });

                // Optionally, reload the event list after editing
                _reloadInformasi();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _onDelete(informasi.id),
          ),
        ],
      )),
    ]);
  }

  @override
  int get rowCount => _informasi.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
