import 'package:flutter/material.dart';
import 'package:ikpm_sidoarjo/admin/layouts/sidebar.dart';

class HomePageAdmin extends StatelessWidget {
  const HomePageAdmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat datang, Admin!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Gunakan menu di sidebar untuk navigasi.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Kelola Pengguna'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              onPressed: () {
                // Tambahkan navigasi ke halaman pengelolaan pengguna
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Kelola Produk'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              onPressed: () {
                // Tambahkan navigasi ke halaman pengelolaan produk
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.analytics),
              label: const Text('Laporan Penjualan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              onPressed: () {
                // Tambahkan navigasi ke halaman laporan penjualan
              },
            ),
          ],
        ),
      ),
    );
  }
}