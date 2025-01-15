import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../layouts/navbar_layout.dart';
import '../layouts/bottom_bar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final stambuk = authProvider.userStambuk;

    if (stambuk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stambuk tidak ditemukan! Silakan login ulang.'),
        ),
      );
      Navigator.pop(context);
      return;
    }

    try {
      final response =
          await http.get(Uri.parse('http://localhost:5001/alumni/$stambuk'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _formData = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final stambuk = authProvider.userStambuk;

    if (stambuk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stambuk tidak ditemukan! Silakan login ulang.'),
        ),
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('http://localhost:5001/alumni/$stambuk'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_formData),
      );

      if (response.statusCode == 200) {
        authProvider.updateProfile(_formData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
        GoRouter.of(context).go('/profil');
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: kIsWeb
          ? const Navbar() // Navbar untuk Web
          : AppBar(
              title: const Text("Edit Profil"),
              backgroundColor: Colors.teal,
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Edit Profil",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Perbarui informasi pribadi Anda",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ..._formData.keys.map((field) {
                            if (field == 'hidden_fields' ||
                                field == 'stambuk') {
                              return Container();
                            }
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                initialValue:
                                    _formData[field]?.toString() ?? '',
                                decoration: InputDecoration(
                                  labelText:
                                      field.replaceAll('_', ' ').toUpperCase(),
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _formData[field] = value;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Footer
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
            ),
      bottomNavigationBar: kIsWeb
          ? null
          : BottomBar(
              currentIndex: 0,
              onTap: (index) {
                if (index == 0) {
                  GoRouter.of(context).go('/profil');
                } else if (index == 1) {
                  GoRouter.of(context).go('/alumni');
                }
              },
            ),
    );
  }
}
