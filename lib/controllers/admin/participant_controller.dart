import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

class ParticipantController {
  final String apiUrl;

  ParticipantController(this.apiUrl);

  Future<List<Map<String, String>>> fetchParticipants(String kegiatanId) async {
    try {
      final response =
          await http.get(Uri.parse('$apiUrl/participations/$kegiatanId'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((participant) {
          return {
            'id': participant['_id']?.toString() ?? 'Unknown',
            'name': participant['name']?.toString() ?? 'Unknown',
            'stambuk': participant['stambuk']?.toString() ?? 'Unknown',
          };
        }).toList();
      } else {
        throw Exception('');
      }
    } catch (e) {
      throw Exception('');
    }
  }

  List<Map<String, String>> filterParticipants(
      List<Map<String, String>> participants, String query) {
    if (query.isEmpty) return List.from(participants);
    return participants
        .where((participant) =>
            participant['name']!.toLowerCase().contains(query.toLowerCase()) ||
            participant['stambuk']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> deleteParticipant(String participantId) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/participations/$participantId'),
    );

    if (response.statusCode == 200) {
      // Successfully deleted the participant
      return;
    } else {
      throw Exception('Failed to delete participant');
    }
  }

  Future<void> generateAndDownloadPdf({
    required String eventName,
    required List<Map<String, String>> participants,
  }) async {
    final pdf = pw.Document();

    // Load the background image (Kop)
    final ByteData data = await rootBundle
        .load('assets/kopsuratikpm.jpg'); // Load the image from assets
    final image = pw.MemoryImage(data.buffer.asUint8List());

    // Add the page with a background image (Kop)
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Background Image (Kop) that covers the entire page
              pw.Positioned.fill(
                child: pw.Image(image,
                    fit:
                        pw.BoxFit.cover), // Fill the entire page with the image
              ),
              // Content (Title and Table)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                      height:
                          100), // Adjust space to avoid overlap with the image
                  pw.Center(
                    child: pw.Text(
                      'Absensi Peserta Kegiatan $eventName',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Table with participants list
                  pw.Table.fromTextArray(
                    border: pw.TableBorder.all(),
                    headers: ['No', 'Stambuk', 'Nama', 'TTD'],
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                    cellAlignment: pw.Alignment.center,
                    data: participants.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final participant = entry.value;
                      return [
                        index.toString(),
                        participant['stambuk']!,
                        participant['name']!,
                        '', // Kosong untuk kolom TTD
                      ];
                    }).toList(),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    if (kIsWeb) {
      // For web platforms
      final bytes = await pdf.save();
      await Printing.sharePdf(
          bytes: bytes, filename: '${eventName}_Participants.pdf');
    } else {
      // For Android and iOS
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
    }
  }
}
