import 'dart:convert';
import 'package:flutter/foundation.dart'; // Untuk deteksi platform
import 'package:http/http.dart' as http;
import '../models/comment_model.dart';

class CommentController {
  late final String _baseUrl;

  CommentController() {
    if (kIsWeb) {
      // URL untuk Web
      _baseUrl = 'https://backend-ikpmsidoarjo.vercel.app';
    } else {
      // URL untuk Android Emulator
      _baseUrl = 'https://backend-ikpmsidoarjo.vercel.app';
    }
  }

  // Ambil komentar berdasarkan informasiId
  Future<List<CommentModel>> fetchComments(String informasiId) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/comments/$informasiId'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((comment) => CommentModel.fromJson(comment))
            .toList();
      } else {
        throw Exception('Gagal mendapatkan komentar: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching comments: $error');
    }
  }

  // Tambahkan komentar baru
  Future<void> addComment(
      String beritaId, String stambuk, String comment) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'beritaId': beritaId,
          'stambuk': stambuk,
          'comment': comment,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Gagal menambahkan komentar: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error adding comment: $error');
    }
  }

  // Edit komentar
  Future<void> editComment(
      String commentId, String stambuk, String newComment) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/comments/$commentId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'stambuk': stambuk, // Validasi berdasarkan stambuk
          'comment': newComment,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal mengedit komentar: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error editing comment: $error');
    }
  }

  // Hapus komentar berdasarkan commentId dan stambuk
  Future<void> deleteComment(String commentId, String stambuk) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/comments/$commentId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'stambuk': stambuk}), // Validasi berdasarkan stambuk
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus komentar: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error deleting comment: $error');
    }
  }
}