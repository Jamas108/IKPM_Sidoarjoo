import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikpm_sidoarjo/controllers/admin/event_controller.dart';
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
  List<EventModel> _filteredEventList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _eventController.fetchEvents();
      setState(() {
        _eventList = events;
        _filteredEventList = List.from(events);
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
      _filteredEventList = _eventController.filterEvents(_eventList, query);
    });
  }

  Future<void> _onDeleteEvent(String kegiatanId) async {
    try {
      final updatedEvents =
          await _eventController.deleteEventAndRefresh(kegiatanId, _eventList);
      setState(() {
        _eventList = updatedEvents;
        _filteredEventList = List.from(updatedEvents);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event: $e')),
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
                              '/admin/events/create'); // Navigasi ke AddEventPage

                          if (newEvent != null && newEvent is EventModel) {
                            setState(() {
                              _eventList.add(newEvent);
                              _filteredEventList.add(newEvent);
                            });
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
                      labelText: 'Search Event',
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
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
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
                              )),
                              DataColumn(
                                  label: Text(
                                'Name',
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold),
                              )),
                              DataColumn(
                                  label: Text(
                                'Date',
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold),
                              )),
                              DataColumn(
                                  label: Text(
                                'Location',
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold),
                              )),
                              DataColumn(
                                  label: Text(
                                'Actions',
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold),
                              )),
                            ],
                            rows:
                                _filteredEventList.asMap().entries.map((entry) {
                              final index = entry.key;
                              final event = entry.value;
                              return DataRow(cells: [
                                DataCell(Text('${index + 1}')), // Nomor urut
                                DataCell(Text(event.name)),
                                DataCell(Text(event.date)),
                                DataCell(Text(event.location)),
                                DataCell(Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility,
                                          color: Colors.blue),
                                      onPressed: () {
                                        context.go(
                                            '/admin/events/detail/${event.id}',
                                            extra: event);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () {
                                        context.go(
                                          '/admin/events/edit/${event.id}',
                                          extra: event,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        final confirmDelete =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Konfirmasi Hapus Kegiatan'),
                                            content: const Text(
                                                'Apakah anda yakin ingin menghapus kegiatan ini?'),
                                            actions: [
                                              TextButton(
                                                child: const Text('Batal'),
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                              ),
                                              TextButton(
                                                child: const Text('Hapus'),
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmDelete == true) {
                                          try {
                                            await _onDeleteEvent(event.id);
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Failed to delete event: $e')),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.people,
                                          color: Colors.green),
                                      onPressed: () {
                                        context.go(
                                          '/admin/events/${event.id}/participants',
                                          extra: {'eventName': event.name},
                                        );
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
