import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';

class ProfilController {
  /// Ambil hidden fields dari backend.
  Future<List<String>> fetchHiddenFields(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final stambuk = authProvider.userStambuk;

    try {
      final response = await http.get(
        Uri.parse('https://backend-ikpmsidoarjo.vercel.app/alumni/$stambuk'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['hidden_fields'] ?? []);
      } else {
        throw Exception('Failed to fetch hidden fields');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil data hidden fields')),
      );
      debugPrint('Error fetching hidden fields: $error');
      return [];
    }
  }

  /// Simpan hidden fields ke backend.
  Future<void> updateHiddenFields(
      BuildContext context, List<String> hiddenFields) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final stambuk = authProvider.userStambuk;

    try {
      final response = await http.post(
        Uri.parse(
            'https://backend-ikpmsidoarjo.vercel.app/hidden_fields/$stambuk'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'hidden_fields': hiddenFields}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil menyembunyikan data')),
        );
      } else {
        throw Exception('Failed to update hidden fields');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Gagal memperbarui data yang disembunyikan')),
      );
      debugPrint('Error updating hidden fields: $error');
    }
  }

  Future<Map<String, dynamic>> fetchProfileData(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final stambuk = authProvider.userStambuk;

    if (stambuk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Stambuk tidak ditemukan! Silakan login ulang.')),
      );
      throw Exception('Stambuk tidak ditemukan');
    }

    try {
      final response = await http.get(
          Uri.parse('https://backend-ikpmsidoarjo.vercel.app/alumni/$stambuk'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  Future<void> saveProfile(
      BuildContext context, Map<String, dynamic> formData) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final stambuk = authProvider.userStambuk;

    if (stambuk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Stambuk tidak ditemukan! Silakan login ulang.')),
      );
      throw Exception('Stambuk tidak ditemukan');
    }

    try {
      final response = await http.put(
        Uri.parse('https://backend-ikpmsidoarjo.vercel.app/alumni/$stambuk'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData),
      );

      if (response.statusCode == 200) {
        authProvider.updateProfile(formData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  Future<void> savePassword(BuildContext context, String newPassword) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final stambuk = authProvider.userStambuk;

    if (stambuk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Stambuk tidak ditemukan! Silakan login ulang.')),
      );
      throw Exception('Stambuk tidak ditemukan');
    }

    try {
      final response = await http.put(
        Uri.parse('https://backend-ikpmsidoarjo.vercel.app/alumni/$stambuk'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'password': newPassword}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diperbarui!')),
        );
      } else {
        throw Exception('Failed to update password');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchKritikByStambuk(
      BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final stambuk = authProvider.userStambuk;

    if (stambuk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Stambuk tidak ditemukan! Silakan login ulang.')),
      );
      throw Exception('Stambuk tidak ditemukan');
    }

    try {
      final response = await http.get(
        Uri.parse('https://backend-ikpmsidoarjo.vercel.app/kritik/$stambuk'),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Gagal memuat riwayat kritik');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  Future<void> editKritik(
      BuildContext context, String kritikId, String updatedKritik) async {
    try {
      final response = await http.put(
        Uri.parse('https://backend-ikpmsidoarjo.vercel.app/kritik/$kritikId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'kritik': updatedKritik}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kritik berhasil diperbarui')),
        );
      } else {
        throw Exception('Gagal memperbarui kritik');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui kritik')),
      );
      debugPrint('Error updating kritik: $error');
    }
  }

  Future<void> deleteKritik(BuildContext context, String kritikId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://backend-ikpmsidoarjo.vercel.app/kritik/$kritikId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kritik berhasil dihapus')),
        );
      } else {
        throw Exception('Gagal menghapus kritik');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus kritik')),
      );
      debugPrint('Error deleting kritik: $error');
    }
  }

  List<Map<String, dynamic>> searchKritik(
      List<Map<String, dynamic>> kritikList, String query) {
    return kritikList.where((kritik) {
      final lowerCaseQuery = query.toLowerCase();
      final kritikText = kritik['kritik']?.toLowerCase() ?? '';
      return kritikText.contains(lowerCaseQuery);
    }).toList();
  }
}
