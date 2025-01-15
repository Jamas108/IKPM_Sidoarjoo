import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/alumni_controller.dart';
import '../layouts/navbar_layout.dart';
import '../layouts/bottom_bar.dart';

class DetailAlumniPage extends StatelessWidget {
  final String stambuk;

  const DetailAlumniPage({Key? key, required this.stambuk}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alumniController =
        Provider.of<AlumniController>(context, listen: false);

    // Reset detail alumni dan hidden fields setiap kali halaman ini dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      alumniController.resetDetailAlumni();
      alumniController.fetchDetailAlumni(stambuk);
    });

    return Scaffold(
      appBar: kIsWeb
          ? const Navbar()
          : AppBar(
              title: const Text('Detail Alumni'),
              backgroundColor: Colors.teal,
            ),
      body: Consumer<AlumniController>(
        builder: (context, alumniController, child) {
          if (alumniController.isDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (alumniController.detailAlumni == null) {
            return const Center(child: Text('Data detail tidak ditemukan'));
          }

          final hiddenFields = alumniController.hiddenFields;

          return Stack(
            children: [
              _buildBackground(),
              SingleChildScrollView(
                padding: const EdgeInsets.only(top: 150.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(alumniController),
                    const SizedBox(height: 24),
                    _buildInfoSection(alumniController, hiddenFields),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: kIsWeb
          ? null
          : BottomBar(
              currentIndex: 1,
              onTap: (index) {
                if (index == 0) {
                  GoRouter.of(context).go('/profile');
                } else if (index == 1) {
                  GoRouter.of(context).go('/alumni');
                }
              },
            ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal, Colors.tealAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      height: 250,
    );
  }

  Widget _buildHeader(AlumniController alumniController) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          child: Text(
            alumniController.detailAlumni!['nama_alumni']?[0].toUpperCase() ??
                "-",
            style: const TextStyle(
              fontSize: 48,
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          alumniController.detailAlumni!['nama_alumni'] ?? 'Nama Tidak Ditemukan',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Stambuk: ${alumniController.detailAlumni!['stambuk'] ?? '-'}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(
      AlumniController alumniController, List<String> hiddenFields) {
    final List<Map<String, dynamic>> infoList = [
      {'icon': Icons.calendar_today, 'title': 'Tahun Alumni', 'key': 'tahun'},
      {'icon': Icons.school, 'title': 'Kampus Asal', 'key': 'kampus_asal'},
      {'icon': Icons.home, 'title': 'Alamat', 'key': 'alamat'},
      {'icon': Icons.phone, 'title': 'No Telepon', 'key': 'no_telepon'},
      {'icon': Icons.favorite, 'title': 'Pasangan', 'key': 'pasangan'},
      {'icon': Icons.work, 'title': 'Pekerjaan', 'key': 'pekerjaan'},
      {'icon': Icons.person, 'title': 'Nama Laqob', 'key': 'nama_laqob'},
      {'icon': Icons.cake, 'title': 'Tempat Tanggal Lahir', 'key': 'ttl'},
      {'icon': Icons.location_city, 'title': 'Kecamatan', 'key': 'kecamatan'},
      {'icon': Icons.apartment, 'title': 'Instansi', 'key': 'instansi'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: infoList.map((info) {
              final key = info['key'];
              final value = hiddenFields.contains(info['title'])
                  ? 'Disembunyikan'
                  : alumniController.detailAlumni![key] ?? '-';
              return _buildInfoRow(info['icon'], info['title'], value);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.teal, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}