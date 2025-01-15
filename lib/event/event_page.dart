import 'package:flutter/foundation.dart'; // Untuk deteksi Web
import 'package:flutter/material.dart';
import '../layouts/navbar_layout.dart'; // Navbar untuk Web
import 'package:go_router/go_router.dart';
import '../controllers/event_controller.dart'; // Controller Event
import '../models/event_model.dart'; // Model Event
import '../layouts/bottom_bar.dart'; // BottomBar untuk Android

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final EventController _eventController = EventController();
  List<EventModel> _eventList = [];
  List<EventModel> _filteredEventList = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 1; // Indeks untuk navigasi BottomBar (Event)

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final events = await _eventController.fetchEvents();
      setState(() {
        _eventList = events;
        _filteredEventList = events;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching events: $error');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load events')),
      );
    }
  }

  void _filterEvents(String query) {
    setState(() {
      _filteredEventList = _eventList
          .where(
              (event) => event.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb; // Deteksi jika platform adalah Web

    return Scaffold(
      appBar: isWeb
          ? const Navbar() // Navbar untuk Web
          : AppBar(
              title: const Text("Event Page"),
              backgroundColor: const Color.fromARGB(255, 23, 114, 110),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (isWeb)
                    // Banner hanya untuk Web
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 2,
                      child: Image.asset(
                        'assets/BANNER.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  // Form Search
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterEvents,
                      decoration: InputDecoration(
                        labelText: 'Cari Event',
                        hintText: 'Masukkan nama event',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  // Daftar Event
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: isWeb
                        ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 12.0,
                              mainAxisSpacing: 12.0,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: _filteredEventList.length,
                            itemBuilder: (context, index) {
                              final event = _filteredEventList[index];
                              return _buildEventCard(event, isWeb);
                            },
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredEventList.length,
                            itemBuilder: (context, index) {
                              final event = _filteredEventList[index];
                              return _buildEventCard(event, isWeb);
                            },
                          ),
                  ),
                  // Tambahkan Padding antara daftar event dan footer
                  const SizedBox(height: 16),
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
      bottomNavigationBar: isWeb
          ? null
          : BottomBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
    );
  }

  Widget _buildEventCard(EventModel event, bool isWeb) {
    return GestureDetector(
      onTap: () {
        context.go(
          '/event/detail/${event.id}',
          extra: {'event': event},
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                height: 140, // Sama seperti di halaman Informasi
                width: double.infinity,
                child: Image.network(
                  event.poster,
                  fit: BoxFit.contain, // Sama seperti di halaman Informasi
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        'No Image',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                event.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Tanggal: ${event.date}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 23, 114, 110),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Lokasi: ${event.location}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 23, 114, 110),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  context.go(
                    '/event/detail/${event.id}',
                    extra: {'event': event},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 23, 114, 110),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Lebih Lengkap',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
