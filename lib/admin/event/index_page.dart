import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikpm_sidoarjo/controllers/admin/kegiatan_controller.dart';
import 'package:ikpm_sidoarjo/models/event_model.dart';
import 'package:ikpm_sidoarjo/admin/layouts/sidebar.dart';
import 'package:go_router/go_router.dart';

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
  int _rowsPerPage = 7; // Number of rows per page for pagination
  int _currentPage = 0; // Current page for pagination

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

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
        SnackBar(content: Text('Failed to load events: $e')),
      );
    }
  }

  void _onSearch(String query) {
    setState(() {
      _filteredKegiatanList = _eventController.filterKegiatan(_eventList, query);
    });
  }

  // Show delete confirmation dialog
  Future<void> _onDeleteKegiatan(String kegiatanId) async {
    bool? deleteConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus kegiatan ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User pressed cancel
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed delete
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed == true) {
      try {
        final updatedEvents = await _eventController.deleteKegiatanAndRefresh(
            kegiatanId, _eventList);
        setState(() {
          _eventList = updatedEvents;
          _filteredKegiatanList = List.from(updatedEvents);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data Kegiatan Berhasil Dihapus')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event: $e')),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0), // Added horizontal padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
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
                              '/admin/events/create'); // Navigate to AddEventPage

                          if (newEvent != null && newEvent is EventModel) {
                            setState(() {
                              _eventList.add(newEvent);
                              _filteredKegiatanList.add(newEvent);
                            });

                            // Reload the event list after adding a new event
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

                  // Card with Table
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0), // Added padding here as well
                        child: _filteredKegiatanList.isEmpty
                            ? const Center(
                                child: Text(
                                  'Data Kegiatan Tidak Ditemukan.',
                                  style: TextStyle(fontSize: 18, color: Colors.red),
                                ),
                              )
                            : SizedBox(
                                width: double.infinity,
                                child: PaginatedDataTable(
                                  rowsPerPage: _filteredKegiatanList.length < _rowsPerPage
                                      ? _filteredKegiatanList.length
                                      : _rowsPerPage,
                                  onPageChanged: (page) {
                                    setState(() {
                                      _currentPage = page;
                                    });
                                  },
                                  columns: const [
                                    DataColumn(
                                        label: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Nama Kegiatan', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Lokasi', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  source: _EventDataSource(
                                      _filteredKegiatanList, _onDeleteKegiatan, context, _loadEvents, setState),
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
  final Function(String) _onDelete;
  final BuildContext _context;
  final Function() _reloadEvents;
  final Function(VoidCallback) _setState;

  _EventDataSource(this._events, this._onDelete, this._context, this._reloadEvents, this._setState);

  @override
  DataRow getRow(int index) {
    final event = _events[index];
    return DataRow(cells: [
      DataCell(Text('${index + 1}')),
      DataCell(Text(event.name)),
      DataCell(Text(event.date)),
      DataCell(Text(event.location)),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.visibility, color: Color.fromARGB(255, 255, 170, 0)),
            onPressed: () {
              _context.go('/admin/events/detail/${event.id}', extra: event);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () async {
              final updatedEvent = await _context.push(
                '/admin/events/edit/${event.id}',
                extra: event,
              );

              if (updatedEvent != null && updatedEvent is EventModel) {
                _setState(() {
                  // Find and replace the old event with the updated one in the list
                  int index = _events.indexWhere((e) => e.id == updatedEvent.id);
                  if (index != -1) {
                    _events[index] = updatedEvent;
                  }
                });

                // Optionally, reload the event list after editing
                _reloadEvents();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _onDelete(event.id),
          ),
          IconButton(
            icon: const Icon(Icons.people, color: Colors.green),
            onPressed: () {
              _context.go(
                '/admin/events/${event.id}/participants',
                extra: {'eventName': event.name},
              );
            },
          ),
        ],
      )),
    ]);
  }

  @override
  int get rowCount => _events.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}