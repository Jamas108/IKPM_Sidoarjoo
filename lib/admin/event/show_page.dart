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
            const SizedBox(height: 20),
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

                    // STATUS DENGAN BADGE BERWARNA
                    _buildStatusBadge(event.status),
                    const SizedBox(height: 16),

                    _buildDetailField('Nama Kegiatan', event.name),
                    const SizedBox(height: 16),
                    _buildDetailField('Tanggal Kegiatan', event.date),
                    const SizedBox(height: 16),
                    _buildDetailField('Waktu Kegiatan', event.time),
                    const SizedBox(height: 16),
                    _buildDetailField('Lokasi Kegiatan', event.location),
                    const SizedBox(height: 16),
                    _buildDetailField('Deskripsi Kegiatan', event.description,
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

  // BADGE STATUS BERWARNA
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    String statusText;

    switch (status) {
      case 'Berjalan':
        bgColor = Colors.green;
        statusText = 'Berjalan';
        break;
      case 'Selesai':
        bgColor = Colors.blue;
        statusText = 'Selesai';
        break;
      case 'Akan Datang':
        bgColor = Colors.orange;
        statusText = 'Akan Datang';
        break;
      case 'Disembunyikan':
        bgColor = Colors.red;
        statusText = 'Disembunyikan';
        break;
      default:
        bgColor = Colors.grey;
        statusText = 'Tidak Diketahui';
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          statusText,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // FIELD DETAIL
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