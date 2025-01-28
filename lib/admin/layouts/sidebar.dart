import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_provider.dart';

class AdminSidebarLayout extends StatelessWidget {
  final Widget child; // Konten utama halaman

  const AdminSidebarLayout({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ambil data pengguna dari AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userStambuk = authProvider.userStambuk ?? 'Tidak Diketahui';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin IKPM Sidoarjo',
          style:
              TextStyle(color: Colors.white), // Ubah warna teks menjadi putih
        ),
        backgroundColor: const Color.fromARGB(255, 23, 114, 110),
        iconTheme: const IconThemeData(
          color: Colors.white, // Ikon drawer menjadi putih
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout,
                color: Colors.white), // Ikon logout putih
            onPressed: () async {
              await authProvider.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 23, 114, 110),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Stambuk: $userStambuk',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Dashboard'),
              onTap: () {
                context.go('/admin/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Kelola Alumni'),
              onTap: () {
                context.go('/admin/alumni');
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Kelola Kegiatan'),
              onTap: () {
                context.go('/admin/events');
              },
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Kelola Informasi'),
              onTap: () {
                context.go('/admin/informasi');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Kelola Kritik & Saran'),
              onTap: () {
                context.go('/admin/kritik');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                context.go('/admin/profil');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await authProvider.logout();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
      body: child, // Tempatkan konten utama di sini
    );
  }
}
