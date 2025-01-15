import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../layouts/navbar_layout.dart'; // Navbar untuk Web
import '../layouts/bottom_bar.dart'; // BottomBar untuk Android

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> allFields = [
    'Tahun Alumni',
    'Kampus Asal',
    'Alamat',
    'No Telepon',
    'Pasangan',
    'Pekerjaan',
    'Nama Laqob',
    'Tempat Tanggal Lahir',
    'Kecamatan',
    'Instansi',
  ];

  List<String> hiddenFields = []; // Daftar field yang disembunyikan

  @override
  void initState() {
    super.initState();
    _fetchHiddenFields();
  }

  // Fungsi untuk mengambil hidden fields dari backend
  Future<void> _fetchHiddenFields() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final stambuk = authProvider.userStambuk;

    try {
      final response =
          await http.get(Uri.parse('https://backend-ikpmsidoarjo.vercel.app/alumni/$stambuk'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Ambil hidden_fields dari data
        setState(() {
          hiddenFields = List<String>.from(data['hidden_fields'] ?? []);
        });
      } else {
        throw Exception('Failed to fetch hidden fields');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil data hidden fields')),
      );
      print('Error fetching hidden fields: $error');
    }
  }

  // Fungsi untuk menyimpan hidden fields ke backend
  Future<void> _updateHiddenFields() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final stambuk = authProvider.userStambuk;

    final response = await http.post(
      Uri.parse('https://backend-ikpmsidoarjo.vercel.app/hidden_fields/$stambuk'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'hidden_fields': hiddenFields}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hidden fields berhasil diperbarui')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui hidden fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb
          ? const Navbar() // Navbar untuk Web
          : AppBar(
              title: const Text('Atur Data yang Disembunyikan'),
              backgroundColor: Colors.teal,
            ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: allFields.length,
              itemBuilder: (context, index) {
                final field = allFields[index];
                return CheckboxListTile(
                  title: Text(field),
                  value: hiddenFields.contains(field),
                  onChanged: (isChecked) {
                    setState(() {
                      if (isChecked == true) {
                        hiddenFields.add(field);
                      } else {
                        hiddenFields.remove(field);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateHiddenFields,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Tambahkan Footer
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            color: const Color(0xFF2C7566),
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: const Center(
              child: Text(
                "© 2025 IKPM Sidoarjo. All Rights Reserved.",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: kIsWeb
          ? null
          : BottomBar(
              currentIndex: 2, // Sesuaikan indeks dengan posisi menu
              onTap: (index) {
                if (index == 0) {
                  GoRouter.of(context).go('/profile');
                } else if (index == 1) {
                  GoRouter.of(context).go('/alumni');
                } else if (index == 2) {
                  GoRouter.of(context).go('/settings');
                }
              },
            ),
    );
  }
}
