import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../models/informasi_model.dart';
import '../controllers/comment_controller.dart';
import '../models/comment_model.dart';
import '../auth/auth_provider.dart';
import '../layouts/navbar_layout.dart';

class DetailInformasi extends StatefulWidget {
  final InformasiModel informasi;

  const DetailInformasi({required this.informasi, Key? key}) : super(key: key);

  @override
  State<DetailInformasi> createState() => _DetailInformasiState();
}

class _DetailInformasiState extends State<DetailInformasi> {
  final CommentController _commentController = CommentController();
  final TextEditingController _commentTextController = TextEditingController();
  List<CommentModel> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      final comments =
          await _commentController.fetchComments(widget.informasi.id);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat komentar: $e')),
      );
    }
  }

  Future<void> _addComment() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? stambuk = authProvider.userStambuk;

    if (stambuk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Silakan login untuk menambahkan komentar!')),
      );
      return;
    }

    final comment = _commentTextController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar tidak boleh kosong!')),
      );
      return;
    }

    try {
      await _commentController.addComment(
          widget.informasi.id, stambuk, comment);
      _commentTextController.clear();
      _fetchComments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar berhasil ditambahkan!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan komentar: $e')),
      );
    }
  }

  Future<void> _deleteComment(String commentId, String stambuk) async {
    try {
      await _commentController.deleteComment(commentId, stambuk);
      _fetchComments(); // Refresh komentar setelah hapus
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar berhasil dihapus!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus komentar: $e')),
      );
    }
  }

  void _showEditCommentDialog(CommentModel comment) {
    final TextEditingController _editController =
        TextEditingController(text: comment.comment);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Komentar'),
          content: TextField(
            controller: _editController,
            decoration: const InputDecoration(hintText: 'Edit komentar...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final newComment = _editController.text.trim();
                if (newComment.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Komentar tidak boleh kosong!')),
                  );
                  return;
                }

                try {
                  await _commentController.editComment(
                      comment.id, comment.stambuk, newComment);
                  Navigator.of(context).pop();
                  _fetchComments(); // Refresh komentar setelah edit
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Komentar berhasil diubah!')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal mengedit komentar: $e')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String commentId, String stambuk) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content:
              const Text('Apakah Anda yakin ingin menghapus komentar ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog
                await _deleteComment(
                    commentId, stambuk); // Panggil fungsi hapus
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb;

    return Scaffold(
      appBar: isWeb
          ? const Navbar()
          : AppBar(
              title: const Text(
                'Detail Informasi',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: true,
            ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Gambar Informasi
            if (widget.informasi.image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.informasi.image,
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.5,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text(
                      'No Image Available',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Nama Informasi
            Center(
              child: Text(
                widget.informasi.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            // Tanggal Informasi
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Text(
                    widget.informasi.date,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Deskripsi Informasi dengan Card full-width
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Judul "Deskripsi Informasi"
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Deskripsi Informasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    // Konten deskripsi
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        widget.informasi.description,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Komentar
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Komentar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Belum ada komentar.',
                            style: TextStyle(fontSize: 16)),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          final String? stambuk = authProvider.userStambuk;

                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(comment.nama),
                            subtitle: Text(comment.comment),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (stambuk == comment.stambuk)
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _showEditCommentDialog(comment),
                                  ),
                                if (stambuk == comment.stambuk)
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _showDeleteConfirmationDialog(
                                            comment.id, stambuk!),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
            const Divider(),
            // Form Tambah Komentar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentTextController,
                      decoration: const InputDecoration(
                        hintText: 'Tulis komentar...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addComment,
                    child: const Text('Kirim'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
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
    );
  }
}
