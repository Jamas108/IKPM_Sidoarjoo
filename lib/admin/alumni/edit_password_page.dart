import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditPasswordAlumniPage extends StatefulWidget {
  final String stambuk;
  const EditPasswordAlumniPage({Key? key, required this.stambuk}) : super(key: key);

  @override
  _EditPasswordAlumniPageState createState() => _EditPasswordAlumniPageState();
}

class _EditPasswordAlumniPageState extends State<EditPasswordAlumniPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentPassword();
  }

  Future<void> _loadCurrentPassword() async {
    final url = Uri.parse('https://backend-ikpmsidoarjo.vercel.app/admin/alumni/${widget.stambuk}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _currentPasswordController.text = data['password'] ?? '';
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch password');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching password: $e')),
      );
    }
  }

  Future<void> _updatePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru tidak cocok')),
      );
      return;
    }

    final url = Uri.parse('https://backend-ikpmsidoarjo.vercel.app/admin/alumni/${widget.stambuk}');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': _newPasswordController.text}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diperbarui')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to update password');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating password: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Password',
          style: TextStyle(color: Colors.white), // Teks AppBar menjadi putih
        ),
        backgroundColor: const Color.fromARGB(255, 23, 114, 110),
        iconTheme: const IconThemeData(color: Colors.white), // Ikon menjadi putih
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _currentPasswordController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Password Saat Ini',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password Baru',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Konfirmasi Password Baru',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _updatePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 23, 114, 110),
                          textStyle: const TextStyle(color: Colors.white), // Teks tombol menjadi putih
                        ),
                        child: const Text('Simpan Perubahan',
                            style: TextStyle(color: Colors.white)), // Teks putih
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}