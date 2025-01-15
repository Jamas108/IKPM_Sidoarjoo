import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class KritikController with ChangeNotifier {
  bool isSubmitting = false;

  // Fungsi untuk mengirim kritik ke server
  Future<void> submitKritik({
    required String stambuk,
    required String nama,
    required String kritik,
  }) async {
    try {
      isSubmitting = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('https://backend-ikpmsidoarjo.vercel.app/kritik'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'stambuk': stambuk,
          'nama': nama,
          'kritik': kritik,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to submit kritik');
      }
    } catch (error) {
      print('Error submitting kritik: $error');
      throw error;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}