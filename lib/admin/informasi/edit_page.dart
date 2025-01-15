import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ikpm_sidoarjo/controllers/admin/informasi_controller.dart';
import 'package:ikpm_sidoarjo/models/informasi_model.dart';

class EditInformasiPage extends StatefulWidget {
  final String informasiId;

  const EditInformasiPage({Key? key, required this.informasiId}) : super(key: key);

  @override
  _EditInformasiPageState createState() => _EditInformasiPageState();
}

class _EditInformasiPageState extends State<EditInformasiPage> {
  InformasiModel? _berita;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Uint8List? _newImageBytes;
  String? _newImageName;
  final InformasiController _informasiController = InformasiController();

  @override
  void initState() {
    super.initState();
    _loadBerita();
  }

  Future<void> _loadBerita() async {
    try {
      final berita = await _informasiController.getBeritaById(widget.informasiId);
      setState(() {
        _berita = berita;
        _titleController.text = berita.name;
        _dateController.text = berita.date;
        _timeController.text = berita.time;
        _descriptionController.text = berita.description;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat informasi: $e')),
      );
    }
  }

  Future<void> _pickNewImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        _newImageBytes = result.files.first.bytes;
        _newImageName = result.files.first.name;
      });
    }
  }

  Future<void> _updateInformasi() async {
    if (_berita == null || !_formKey.currentState!.validate()) return;

    try {
      await _informasiController.updateInformasi(
        id: _berita!.id,
        name: _titleController.text,
        date: _dateController.text,
        time: _timeController.text,
        description: _descriptionController.text,
        imageBytes: _newImageBytes,
        imageName: _newImageName,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berita berhasil diperbarui')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui berita: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Berita',
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 23, 114, 110),
      ),
      body: _berita == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_newImageBytes != null || (_berita!.image.isNotEmpty))
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _newImageBytes != null
                          ? Image.memory(
                              _newImageBytes!,
                              width: 300,
                              height: 300,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              _berita!.image,
                              width: 300,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ElevatedButton(
                    onPressed: _pickNewImage,
                    child: const Text('Pilih Gambar Baru'),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(_titleController, 'Judul'),
                        _buildTextField(_dateController, 'Tanggal'),
                        _buildTextField(_timeController, 'Waktu'),
                        _buildTextField(_descriptionController, 'Deskripsi',
                            maxLines: 5),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _updateInformasi,
                          child: const Text('Perbarui'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label wajib diisi';
          }
          return null;
        },
      ),
    );
  }
}