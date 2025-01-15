import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginController with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> handleLogin(String stambuk, String password, BuildContext context) async {
    if (stambuk.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stambuk dan password tidak boleh kosong')),
      );
      return;
    }

    isLoading = true;

    try {
      final response = await http.post(
        Uri.parse('https://backend-ikpmsidoarjo.vercel.app/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'stambuk': stambuk, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final user = responseData['user'];

        if (user != null) {
          Provider.of<AuthProvider>(context, listen: false).login(
            user['stambuk'] ?? '',
            user['nama'] ?? 'Tidak Diketahui',
            user['tahun'] ?? '',
            user['kampus_asal'] ?? '',
            user['alamat'] ?? '',
            user['no_telepon'] ?? '',
            user['pasangan'] ?? '',
            user['pekerjaan'] ?? '',
            user['nama_laqob'] ?? '',
            user['ttl'] ?? '',
            user['kecamatan'] ?? '',
            user['instansi'] ?? '',
            password,
            user['role_id'] ?? 0,
          );

          if (user['role_id'] == 1) {
            context.go('/admin/dashboard');
          } else {
            context.go('/');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User tidak ditemukan')),
          );
        }
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['error'] ?? 'Login gagal')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      isLoading = false;
    }
  }

  void navigateToRegister(BuildContext context) {
    context.go('/register');
  }
}