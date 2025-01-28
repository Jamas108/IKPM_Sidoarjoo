import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ikpm_sidoarjo/controllers/admin/informasi_controller.dart';
import 'package:ikpm_sidoarjo/controllers/comment_controller.dart';
import 'package:ikpm_sidoarjo/models/comment_model.dart';
import 'package:ikpm_sidoarjo/models/informasi_model.dart';
import 'package:ikpm_sidoarjo/auth/auth_provider.dart';

class ShowInformasiPage extends StatefulWidget {
  final String informasiId;

  const ShowInformasiPage({Key? key, required this.informasiId}) : super(key: key);

  @override
  _ShowInformasiPageState createState() => _ShowInformasiPageState();
}

class _ShowInformasiPageState extends State<ShowInformasiPage> {
  InformasiModel? _berita;
  final CommentController _commentController = CommentController();
  final TextEditingController _commentControllerField = TextEditingController();
  List<CommentModel> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBerita();
    _loadComments();
  }

  // Memuat data berita berdasarkan informasiId
  Future<void> _loadBerita() async {
    try {
      final informasiController = InformasiController();
      final berita = await informasiController.getBeritaById(widget.informasiId);
      setState(() {
        _berita = berita;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat informasi: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Memuat komentar untuk berita berdasarkan informasiId
  Future<void> _loadComments() async {
    try {
      final comments = await _commentController.fetchComments(widget.informasiId);
      setState(() {
        _comments = comments;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat komentar: $e')),
      );
    }
  }

  // Menambahkan komentar baru
  Future<void> _addComment(String comment) async {
    try {
      // Ambil stambuk pengguna yang sedang login dari AuthProvider
      final stambuk = Provider.of<AuthProvider>(context, listen: false).userStambuk;

      if (stambuk == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stambuk tidak ditemukan.')),
        );
        return;
      }

      await _commentController.addComment(widget.informasiId, stambuk, comment);
      setState(() {
        _comments.add(CommentModel(
          id: DateTime.now().toString(),
          informasiId: widget.informasiId,
          comment: comment,
          stambuk: stambuk,
          nama: 'Admin', // Atau ganti sesuai data pengguna
          createdAt: DateTime.now().toString(),
          updatedAt: DateTime.now().toString(),
        ));
      });
      _commentControllerField.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar berhasil ditambahkan')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan komentar: $e')),
      );
    }
  }

  // Menghapus komentar berdasarkan ID
  Future<void> _deleteComment(String commentId, String stambuk) async {
    try {
      await _commentController.deleteComment(commentId, stambuk);
      setState(() {
        _comments.removeWhere((comment) => comment.id == commentId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus komentar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Informasi',
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 23, 114, 110),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _berita == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Gambar poster di dalam Card bersama form input
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              if (_berita!.image.isNotEmpty)
                                Image.network(
                                  _berita!.image,
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.cover,
                                ),
                              const SizedBox(height: 20),
                              // Form untuk menampilkan informasi dalam Card yang sama
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      initialValue: _berita!.name,
                                      decoration: const InputDecoration(
                                        labelText: 'Judul',
                                        border: OutlineInputBorder(),
                                      ),
                                      readOnly: true,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      initialValue: _berita!.date,
                                      decoration: const InputDecoration(
                                        labelText: 'Tanggal',
                                        border: OutlineInputBorder(),
                                      ),
                                      readOnly: true,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      initialValue: _berita!.time,
                                      decoration: const InputDecoration(
                                        labelText: 'Waktu',
                                        border: OutlineInputBorder(),
                                      ),
                                      readOnly: true,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      initialValue: _berita!.description,
                                      decoration: const InputDecoration(
                                        labelText: 'Deskripsi',
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLines: 5,
                                      readOnly: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Komentar
                      Text(
                        'Komentar',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _comments.isEmpty
                          ? const Text('Belum ada komentar.')
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _comments.length,
                              itemBuilder: (context, index) {
                                final comment = _comments[index];
                                return Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    title: Text(
                                      comment.nama,
                                      style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(comment.comment),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        final confirmDelete =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                                'Konfirmasi Hapus'),
                                            content: const Text(
                                                'Anda yakin ingin menghapus komentar ini?'),
                                            actions: [
                                              TextButton(
                                                child: const Text('Batal'),
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                              ),
                                              TextButton(
                                                child: const Text('Hapus'),
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmDelete == true) {
                                          await _deleteComment(
                                              comment.id, comment.stambuk);
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 20),
                      // Tambah Komentar
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _commentControllerField,
                                decoration: const InputDecoration(
                                  labelText: 'Tambahkan Komentar',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  if (_commentControllerField
                                      .text.isNotEmpty) {
                                    _addComment(
                                        _commentControllerField.text);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                      255, 23, 114, 110),
                                ),
                                child: const Text(
                                  'Kirim',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}