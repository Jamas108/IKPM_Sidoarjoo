import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikpm_sidoarjo/controllers/admin/participant_controller.dart';

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
  final ParticipantController _participantController =
      ParticipantController('https://backend-ikpmsidoarjo.vercel.app');
  List<Map<String, String>> participantsList = [];
  List<Map<String, String>> filteredParticipantsList = [];
  bool isLoading = true;
  String searchQuery = '';
  bool noParticipantsFound = false;

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  Future<void> _fetchParticipants() async {
    try {
      final participants =
          await _participantController.fetchParticipants(widget.kegiatanId);
      setState(() {
        participantsList = participants;
        filteredParticipantsList = List.from(participants);
        isLoading = false;
        if (participants.isEmpty) {
          noParticipantsFound = true;
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterParticipants(String query) {
    setState(() {
      searchQuery = query;
      filteredParticipantsList =
          _participantController.filterParticipants(participantsList, query);
    });
  }

  void _downloadPdf() async {
    if (filteredParticipantsList.isNotEmpty) {
      await _participantController.generateAndDownloadPdf(
        eventName: widget.eventName,
        participants: filteredParticipantsList,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil Cetak PDF!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data peserta untuk dicetak menjadi PDF.')),
      );
    }
  }

  // Function to delete a participant with confirmation
  Future<void> _deleteParticipant(String participantId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus peserta ini?'),
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

    if (confirmDelete == true) {
      try {
        await _participantController.deleteParticipant(participantId);
        setState(() {
          filteredParticipantsList.removeWhere(
              (participant) => participant['id'] == participantId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participant deleted!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete participant: $e')),
        );
      }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadPdf,
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: _filterParticipants,
                    decoration: const InputDecoration(
                      labelText: 'Cari Peserta',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (noParticipantsFound)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Belum ada peserta kegiatan',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  filteredParticipantsList.isEmpty && !noParticipantsFound
                      ? const Center(child: Text('Belum Ada Peserta Kegiatan'))
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
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      _deleteParticipant(participant['id']!);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}