import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:ikpm_sidoarjo/controllers/admin/kegiatan_controller.dart';
import 'package:ikpm_sidoarjo/models/event_model.dart';
import 'package:ikpm_sidoarjo/admin/layouts/sidebar.dart';
import 'package:ikpm_sidoarjo/admin/event/edit_page.dart';

class EventPageAdmin extends StatefulWidget {
  const EventPageAdmin({Key? key}) : super(key: key);

  @override
  _EventPageAdminState createState() => _EventPageAdminState();
}

class _EventPageAdminState extends State<EventPageAdmin> {
  final EventController _eventController = EventController();
  List<EventModel> _eventList = [];
  List<EventModel> _filteredKegiatanList = [];
  bool _isLoading = true;
  int _rowsPerPage = 7; // Jumlah baris per halaman

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // Fungsi untuk memuat data event dari backend
  Future<void> _loadEvents() async {
    try {
      final events = await _eventController.fetchKegiatan();
      setState(() {
        _eventList = events;
        _filteredKegiatanList = List.from(events);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat kegiatan: $e')),
      );
    }
  }

  // Fungsi pencarian kegiatan
  void _onSearch(String query) {
    setState(() {
      _filteredKegiatanList =
          _eventController.filterKegiatan(_eventList, query);
    });
  }

  // Fungsi untuk menangkap perubahan setelah edit
  void _navigateToEditPage(EventModel event) async {
    final updatedEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventPage(event: event),
      ),
    );

    if (updatedEvent != null && updatedEvent is EventModel) {
      setState(() {
        int index = _eventList.indexWhere((e) => e.id == updatedEvent.id);
        if (index != -1) {
          _eventList[index] = updatedEvent;
          _filteredKegiatanList[index] = updatedEvent;
        }
      });
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
                        'Kelola Kegiatan',
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final newEvent = await context.push(
                              '/admin/events/create'); // Navigasi ke halaman tambah kegiatan

                          if (newEvent != null && newEvent is EventModel) {
                            setState(() {
                              _eventList.add(newEvent);
                              _filteredKegiatanList.add(newEvent);
                            });

                            await _loadEvents();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C7566),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Tambah Kegiatan',
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
                      labelText: 'Cari Kegiatan',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Card dengan Tabel
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _filteredKegiatanList.isEmpty
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
                                  rowsPerPage: _filteredKegiatanList.length <
                                          _rowsPerPage
                                      ? _filteredKegiatanList.length
                                      : _rowsPerPage,
                                  columns: const [
                                    DataColumn(
                                        label: Text('No',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Nama Kegiatan',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Tanggal',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Lokasi',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Status',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Aksi',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                  ],
                                  source: _EventDataSource(
                                      _filteredKegiatanList,
                                      _navigateToEditPage,
                                      context),
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

class _EventDataSource extends DataTableSource {
  final List<EventModel> _events;
  final Function(EventModel) _onEdit;
  final BuildContext _context;

  _EventDataSource(this._events, this._onEdit, this._context);

  @override
  DataRow getRow(int index) {
    final event = _events[index];

    return DataRow(cells: [
      DataCell(Text('${index + 1}')),
      DataCell(Text(event.name)),
      DataCell(Text(event.date)),
      DataCell(Text(event.location)),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(event.status),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            event.status,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.visibility, color: Colors.orange),
            onPressed: () {
              _context.go('/admin/events/detail/${event.id}', extra: event);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _onEdit(event),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => {}, // Tambahkan fungsi hapus
          ),
        ],
      )),
    ]);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Berjalan':
        return Colors.green;
      case 'Selesai':
        return Colors.blue;
      case 'Akan Datang':
        return Colors.orange;
      case 'Sembunyikan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  int get rowCount => _events.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
