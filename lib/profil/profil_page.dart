import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../layouts/navbar_layout.dart';
import '../layouts/bottom_bar.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: kIsWeb
          ? const Navbar() // Navbar untuk Web
          : AppBar(
              title: const Text(
                "Profil Anda",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20, // Ukuran font lebih besar
                  fontWeight:
                      FontWeight.w600, // Berat font medium untuk kesan elegan
                  fontFamily: 'Roboto', // Gunakan font elegan, contoh: Roboto
                  letterSpacing: 1.2, // Memberikan spasi antar huruf
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 23, 114, 110),
            ),
      body: authProvider.isLoggedIn
          ? Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      _buildBackground(),
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 35.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildProfileHeader(authProvider),
                            const SizedBox(height: 24),
                            _buildInfoSection(authProvider),
                            const SizedBox(height: 24),
                            _buildSettingsButton(context),
                            const SizedBox(height: 16), // Spasi antara tombol
                            _buildHistoryEventButton(context),
                            const SizedBox(height: 16),
                            _buildHistoryKritikButton(context),
                            const SizedBox(height: 16), // Spasi antara tombol
                            _buildEditProfileButton(context),
                            const SizedBox(height: 16),
                            _buildEditPasswordButton(context),
                            const SizedBox(height: 16),
                            _buildLogoutButton(context),
                            const SizedBox(height: 16), // Tambahkan tombol baru
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Tambahkan Footer
              ],
            )
          : const Center(
              child: Text(
                'Anda harus melakukan login terlebih dahulu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
      bottomNavigationBar: kIsWeb
          ? null
          : BottomBar(
              currentIndex: 0, // Sesuaikan dengan posisi menu di navbar
              onTap: (index) {
                // Handle perubahan halaman sesuai dengan index navbar
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

  Widget _buildProfileHeader(AuthProvider authProvider) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          child: Text(
            authProvider.userNama != null
                ? authProvider.userNama![0].toUpperCase()
                : "-",
            style: const TextStyle(
              fontSize: 48,
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          authProvider.userNama ?? 'Nama Tidak Ditemukan',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Stambuk: ${authProvider.userStambuk ?? '-'}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(AuthProvider authProvider) {
    final List<Map<String, dynamic>> infoList = [
      {
        'icon': Icons.calendar_today,
        'title': 'Tahun Alumni',
        'value': authProvider.userTahun
      },
      {
        'icon': Icons.school,
        'title': 'Kampus Asal',
        'value': authProvider.userKampusAsal
      },
      {'icon': Icons.home, 'title': 'Alamat', 'value': authProvider.userAlamat},
      {
        'icon': Icons.phone,
        'title': 'No Telepon',
        'value': authProvider.userNoTelepon
      },
      {
        'icon': Icons.favorite,
        'title': 'Pasangan',
        'value': authProvider.userPasangan
      },
      {
        'icon': Icons.work,
        'title': 'Pekerjaan',
        'value': authProvider.userPekerjaan
      },
      {
        'icon': Icons.person,
        'title': 'Nama Laqob',
        'value': authProvider.userNamaLaqob
      },
      {
        'icon': Icons.cake,
        'title': 'Tempat Tanggal Lahir',
        'value': authProvider.userTtl
      },
      {
        'icon': Icons.location_city,
        'title': 'Kecamatan',
        'value': authProvider.userKecamatan
      },
      {
        'icon': Icons.apartment,
        'title': 'Instansi',
        'value': authProvider.userInstansi
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: infoList
                .map((info) =>
                    _buildInfoRow(info['icon'], info['title'], info['value']))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String? value) {
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
              value ?? '-',
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

  Widget _buildSettingsButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            GoRouter.of(context).go('/settings');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text(
            'Atur Data yang Disembunyikan',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryEventButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            GoRouter.of(context)
                .go('/riwayat-event'); // Navigasi ke RiwayatEventPage
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text(
            'Riwayat Kegiatan',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryKritikButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            GoRouter.of(context)
                .go('/riwayat-kritik'); // Navigasi ke RiwayatEventPage
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text(
            'Riwayat Kritik dan Saran',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            GoRouter.of(context)
                .go('/edit-profile'); // Navigasi ke RiwayatEventPage
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text(
            'Edit Profil',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildEditPasswordButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showPasswordModal(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Ganti Password',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> _showPasswordModal(BuildContext context) async {
    String currentPassword = '';
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Masukkan Password'),
          content: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Password Saat Ini',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            onChanged: (value) => currentPassword = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (currentPassword == authProvider.userPassword) {
                  Navigator.pop(context); // Tutup modal
                  GoRouter.of(context).go('/edit-password');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password salah')),
                  );
                }
              },
              child: const Text('Lanjutkan'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            await authProvider.logout(); // Hapus sesi pengguna
            if (context.mounted) {
              GoRouter.of(context).go('/'); // Redirect ke path root
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 0, 0),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Keluar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
