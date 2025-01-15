import 'package:flutter/material.dart';
import 'package:ikpm_sidoarjo/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowEventPage extends StatelessWidget {
  final EventModel event;

  const ShowEventPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Kegiatan',
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 23, 114, 110),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Event
            if (event.poster.isNotEmpty)
              Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.network(
                    event.poster,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // Detail Event
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Event',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailField('Nama Event', event.name),
                    const SizedBox(height: 16),
                    _buildDetailField('Tanggal Event', event.date),
                    const SizedBox(height: 16),
                    _buildDetailField('Waktu Event', event.time),
                    const SizedBox(height: 16),
                    _buildDetailField('Lokasi Event', event.location),
                    const SizedBox(height: 16),
                    _buildDetailField('Deskripsi Event', event.description,
                        maxLines: 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, String value, {int maxLines = 1}) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      readOnly: true,
    );
  }
}
