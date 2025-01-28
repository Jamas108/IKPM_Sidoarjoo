import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      alumniController.resetDetailAlumni();
      alumniController.fetchDetailAlumni(stambuk);
    });

    return Scaffold(
      appBar: kIsWeb
          ? const Navbar()
          : AppBar(
              title: const Text(
                'Detail Alumni',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  letterSpacing: 1.2,
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 23, 114, 110),
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
              automaticallyImplyLeading: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  GoRouter.of(context).go('/alumni');
                },
              ),
            ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<AlumniController>(
              builder: (context, alumniController, child) {
                if (alumniController.isDetailLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (alumniController.detailAlumni == null) {
                  return const Center(child: Text('Data detail tidak ditemukan'));
                }

                final hiddenFields = alumniController.hiddenFields;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildHeaderCard(alumniController),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Informasi Alumni'),
                        const SizedBox(height: 10),
                        _buildInfoSection(
                          alumniController,
                          hiddenFields,
                          [
                            {
                              'icon': Icons.person,
                              'title': 'Nama',
                              'key': 'nama_alumni'
                            },
                            {
                              'icon': Icons.confirmation_number,
                              'title': 'Stambuk',
                              'key': 'stambuk'
                            },
                            {
                              'icon': Icons.calendar_today,
                              'title': 'Tahun Alumni',
                              'key': 'tahun'
                            },
                            {
                              'icon': Icons.school,
                              'title': 'Kampus Asal',
                              'key': 'kampus_asal'
                            },
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Kontak dan Alamat'),
                        const SizedBox(height: 10),
                        _buildInfoSection(
                          alumniController,
                          hiddenFields,
                          [
                            {
                              'icon': Icons.home,
                              'title': 'Alamat',
                              'key': 'alamat'
                            },
                            {
                              'icon': Icons.phone,
                              'title': 'No Telepon',
                              'key': 'no_telepon'
                            },
                            {
                              'icon': Icons.people,
                              'title': 'Pasangan',
                              'key': 'pasangan'
                            },
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Pekerjaan'),
                        const SizedBox(height: 10),
                        _buildInfoSection(
                          alumniController,
                          hiddenFields,
                          [
                            {
                              'icon': Icons.work,
                              'title': 'Pekerjaan',
                              'key': 'pekerjaan'
                            },
                            {
                              'icon': Icons.badge,
                              'title': 'Nama Laqob',
                              'key': 'nama_laqob'
                            },
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Informasi Lain'),
                        const SizedBox(height: 10),
                        _buildInfoSection(
                          alumniController,
                          hiddenFields,
                          [
                            {'icon': Icons.cake, 'title': 'TTL', 'key': 'ttl'},
                            {
                              'icon': Icons.location_city,
                              'title': 'Kecamatan',
                              'key': 'kecamatan'
                            },
                            {
                              'icon': Icons.apartment,
                              'title': 'Instansi',
                              'key': 'instansi'
                            },
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Consumer<AlumniController>(
            builder: (context, alumniController, child) {
              if (alumniController.detailAlumni == null) return const SizedBox();

              final detail = alumniController.detailAlumni!;
              final namaAlumni = detail['nama_alumni'] ?? '-';
              final stambuk = detail['stambuk'] ?? '-';

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final waNumber = '+6281233908357';
                      final message =
                          "Assalamualaikum, perkenalkan [nama anda], saya ingin meminta data detail alumni atas nama \"$namaAlumni\" dengan stambuk \"$stambuk\" apakah boleh?";
                      final waUrl =
                          'https://wa.me/$waNumber?text=${Uri.encodeComponent(message)}';
                      launchWhatsApp(waUrl);
                    },
                    icon: const Icon(Icons.call_end_outlined, color: Colors.white),
                    label: const Text(
                      'Minta Data Detail',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
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

  void launchWhatsApp(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildHeaderCard(AlumniController alumniController) {
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
              child: Text(
                alumniController.detailAlumni!['nama_alumni']?[0]
                        .toUpperCase() ??
                    "-",
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alumniController.detailAlumni!['nama_alumni'] ??
                        'Nama Tidak Ditemukan',
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Stambuk: ${alumniController.detailAlumni!['stambuk'] ?? '-'}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    'Tahun Alumni: ${alumniController.detailAlumni!['tahun'] ?? '-'}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                    ),
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

  Widget _buildInfoSection(
    AlumniController alumniController,
    List<String> hiddenFields,
    List<Map<String, dynamic>> infoList,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: infoList.map((info) {
        final key = info['key'];
        final value = hiddenFields.contains(info['title'])
            ? 'Disembunyikan'
            : alumniController.detailAlumni![key] ?? '-';
        return _buildDetailRow(info['icon'], info['title'], value);
      }).toList(),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    final isHidden = value == 'Disembunyikan';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (isHidden)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Disembunyikan',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (!isHidden)
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}