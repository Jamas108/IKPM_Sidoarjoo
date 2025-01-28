import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ikpm_sidoarjo/controllers/admin/informasi_controller.dart';
import 'package:ikpm_sidoarjo/models/informasi_model.dart';

class EditInformasiPage extends StatefulWidget {
  final String informasiId;

  const EditInformasiPage({Key? key, required this.informasiId})
      : super(key: key);

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
    _loadInformasi();
  }

  // Fetch the Informasi object by its ID
  Future<void> _loadInformasi() async {
    try {
      final informasi =
          await _informasiController.getBeritaById(widget.informasiId);
      setState(() {
        _berita = informasi;
        _titleController.text = informasi.name;
        _dateController.text = informasi.date;
        _timeController.text = informasi.time;
        _descriptionController.text = informasi.description;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat informasi: $e')),
      );
    }
  }

  // Method to pick a new image for the event
  Future<void> _pickNewImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _newImageBytes = result.files.first.bytes;
        _newImageName = result.files.first.name;
      });
    }
  }

  // Method to update the Informasi details
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

      final updatedInformasi = InformasiModel(
        id: _berita!.id,
        name: _titleController.text,
        date: _dateController.text,
        time: _timeController.text,
        description: _descriptionController.text,
        image: _newImageName ??
            _berita!.image, // Keep the same image or change if updated
      );

      Navigator.pop(context, updatedInformasi); // Returning updated Informasi

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informasi berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Informasi',
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 23, 114, 110),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _berita == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (_newImageBytes != null || (_berita!.image.isNotEmpty))
                        Center(
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
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _pickNewImage,
                        child: const Text(
                          'Pilih Gambar Baru',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                                _titleController, 'Judul Informasi', Icons.book),
                            _buildTextField(
                                _dateController, 'Tanggal Informasi', Icons.date_range),
                            _buildTextField(_timeController, 'Waktu Informasi', Icons.access_time),
                            _buildTextField(
                                _descriptionController, 'Deskripsi Informasi',Icons.description,
                                maxLines: 5),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _updateInformasi,
                                child: const Text(
                                  'Perbarui Informasi',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C7566),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Helper method to build text fields with validation
  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
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
