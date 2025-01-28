import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ikpm_sidoarjo/controllers/profil_controller.dart';
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

  List<String> hiddenFields = [];
  final ProfilController _profilController = ProfilController();

  @override
  void initState() {
    super.initState();
    _loadHiddenFields();
  }

  void _loadHiddenFields() async {
    final fields = await _profilController.fetchHiddenFields(context);
    setState(() {
      hiddenFields = fields;
    });
  }

  void _saveHiddenFields() async {
    await _profilController.updateHiddenFields(context, hiddenFields);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb
          ? const Navbar()
          : AppBar(
              title: const Text(
                'Sembunyikan Data',
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
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
              automaticallyImplyLeading: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  GoRouter.of(context).go('/profil');
                },
              ),
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
                onPressed: _saveHiddenFields,
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
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: kIsWeb
          ? null
          : BottomBar(
              currentIndex: 2,
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
