import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EventParticipantsPage extends StatefulWidget {
  final String kegiatanId;
  final String eventName;

  const EventParticipantsPage({
    Key? key,
    required this.kegiatanId,
    required this.eventName,
  }) : super(key: key);

  @override
  _EventParticipantsPageState createState() => _EventParticipantsPageState();
}

class _EventParticipantsPageState extends State<EventParticipantsPage> {
  List<Map<String, String>> participantsList = [];
  List<Map<String, String>> filteredParticipantsList = [];
  bool isLoading = true;
  String searchQuery = '';
  bool noParticipantsFound = false;

  @override
  void initState() {
    super.initState();
    fetchParticipants();
  }

  Future<void> fetchParticipants() async {
    try {
      final response = await http.get(
          Uri.parse('https://backend-ikpmsidoarjo.vercel.app/participations/${widget.kegiatanId}'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          participantsList = jsonData.map((participant) {
            return {
              'id': participant['_id']?.toString() ?? 'Unknown',
              'name': participant['name']?.toString() ?? 'Unknown',
              'stambuk': participant['stambuk']?.toString() ?? 'Unknown',
            };
          }).toList();
          filteredParticipantsList = List.from(participantsList);
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load participants')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching participants: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterParticipants(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredParticipantsList = List.from(participantsList);
      } else {
        filteredParticipantsList = participantsList
            .where((participant) =>
                participant['name']!
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                participant['stambuk']!
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }

      Future.delayed(const Duration(seconds: 3), () {
        if (filteredParticipantsList.isEmpty) {
          setState(() {
            noParticipantsFound = true;
          });
        } else {
          setState(() {
            noParticipantsFound = false;
          });
        }
      });
    });
  }

  Future<void> generateAndDownloadPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Peserta Kegiatan: ${widget.eventName}',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              border: pw.TableBorder.all(),
              headers: ['No', 'Stambuk', 'Nama', 'TTD'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 14,
              ),
              cellAlignment: pw.Alignment.center,
              data: filteredParticipantsList.asMap().entries.map((entry) {
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
      ),
    );

    if (kIsWeb) {
      // Untuk platform web
      final bytes = await pdf.save();
      await Printing.sharePdf(
          bytes: bytes, filename: '${widget.eventName}_Participants.pdf');
    } else {
      // Untuk Android dan iOS
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Peserta - ${widget.eventName}',
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C7566),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: filterParticipants,
                    decoration: const InputDecoration(
                      labelText: 'Search Participant',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (noParticipantsFound)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Peserta Tidak Ditemukan',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  filteredParticipantsList.isEmpty && !noParticipantsFound
                      ? const Center(child: Text('No participants available'))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: filteredParticipantsList.length,
                            itemBuilder: (context, index) {
                              final participant =
                                  filteredParticipantsList[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text('Nama: ${participant['name']}'),
                                  subtitle: Text(
                                      'Stambuk: ${participant['stambuk']}'),
                                ),
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 16),
                  // Tombol Download PDF
                  ElevatedButton.icon(
                    onPressed: () {
                      if (filteredParticipantsList.isNotEmpty) {
                        generateAndDownloadPdf();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('PDF Downloaded!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('No participants to download.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C7566), // Warna tombol
                      foregroundColor: Colors.white, // Warna teks tombol
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
