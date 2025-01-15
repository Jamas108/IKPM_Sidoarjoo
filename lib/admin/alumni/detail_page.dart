import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AlumniDetailPage extends StatefulWidget {
  final String stambuk;
  const AlumniDetailPage({Key? key, required this.stambuk}) : super(key: key);

  @override
  _AlumniDetailPageState createState() => _AlumniDetailPageState();
}

class _AlumniDetailPageState extends State<AlumniDetailPage> {
  Map<String, dynamic>? _alumniData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlumniDetail();
  }

  Future<void> _fetchAlumniDetail() async {
    try {
      const String apiUrl = 'https://backend-ikpmsidoarjo.vercel.app/admin/alumni'; // Ganti URL ini
      final response = await http.get(Uri.parse('$apiUrl/${widget.stambuk}'));

      if (response.statusCode == 200) {
        setState(() {
          _alumniData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch alumni details: ${response.body}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: const Text('Detail Alumni'),
        backgroundColor: const Color.fromARGB(255, 23, 114, 110),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alumniData == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        _buildHeaderCard(),
                        const SizedBox(height: 20),
                        // Informasi Alumni
                        _buildSectionTitle('Informasi Alumni'),
                        const SizedBox(height: 10),
                        _buildDetailRow(Icons.person, 'Nama', _alumniData!['nama']),
                        _buildDetailRow(Icons.confirmation_number, 'Stambuk', _alumniData!['stambuk']),
                        _buildDetailRow(Icons.date_range, 'Tahun Lulus', _alumniData!['tahun']),
                        _buildDetailRow(Icons.school, 'Kampus Asal', _alumniData!['kampus_asal']),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Kontak dan Alamat'),
                        const SizedBox(height: 10),
                        _buildDetailRow(Icons.home, 'Alamat', _alumniData!['alamat']),
                        _buildDetailRow(Icons.phone, 'No. Telepon', _alumniData!['no_telepon']),
                        _buildDetailRow(Icons.people, 'Pasangan', _alumniData!['pasangan'] ?? '-'),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Pekerjaan'),
                        const SizedBox(height: 10),
                        _buildDetailRow(Icons.work, 'Pekerjaan', _alumniData!['pekerjaan']),
                        _buildDetailRow(Icons.badge, 'Nama Laqob', _alumniData!['nama_laqob'] ?? '-'),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Informasi Lain'),
                        const SizedBox(height: 10),
                        _buildDetailRow(Icons.cake, 'TTL', _alumniData!['ttl']),
                        _buildDetailRow(Icons.map, 'Kecamatan', _alumniData!['kecamatan']),
                        _buildDetailRow(Icons.business, 'Instansi', _alumniData!['instansi'] ?? '-'),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: Colors.teal.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.teal,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _alumniData!['nama'] ?? '',
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Stambuk: ${_alumniData!['stambuk'] ?? '-'}',
                    style: const TextStyle(fontSize: 16.0, color: Colors.black54),
                  ),
                  Text(
                    'Tahun Lulus: ${_alumniData!['tahun'] ?? '-'}',
                    style: const TextStyle(fontSize: 16.0, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16.0, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}