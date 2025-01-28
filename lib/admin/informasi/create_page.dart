import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ikpm_sidoarjo/models/informasi_model.dart';
import 'package:intl/intl.dart';
import 'package:ikpm_sidoarjo/controllers/admin/informasi_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class AddInformasiPage extends StatefulWidget {
  const AddInformasiPage({Key? key}) : super(key: key);

  @override
  _AddInformasiPageState createState() => _AddInformasiPageState();
}

class _AddInformasiPageState extends State<AddInformasiPage> {
  final InformasiController _informasiController = InformasiController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Uint8List? _selectedImage;
  String? _selectedImageName;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        _selectedImage = file.bytes;
        _selectedImageName = file.name;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _saveInformasi() async {
    String title = titleController.text;
    String date = dateController.text;
    String time = timeController.text;
    String description = descriptionController.text;

    if (title.isEmpty ||
        date.isEmpty ||
        time.isEmpty ||
        description.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom wajib diisi')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Aktifkan indikator loading
    });

    try {
      await _informasiController.addInformasi(
        title: title,
        date: date,
        time: time,
        description: description,
        imageBytes: _selectedImage,
        imageName: _selectedImageName,
      );

      // Return the newly created Informasi object to the previous page
      Navigator.pop(
          context,
          InformasiModel(
            id: 'newId', // You should get the actual ID from the backend response
            name: title,
            date: date,
            time: time,
            description: description,
            image: 'posterPath', // If you have a poster, include its path here
          ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informasi berhasil ditambahkan')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat menyimpan informasi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Matikan indikator loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Informasi',
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 23, 114, 110),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: titleController,
                    label: 'Judul Informasi',
                    icon: Icons.article,
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: dateController,
                        label: 'Tanggal Informasi',
                        icon: Icons.calendar_today,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _selectTime(context),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: timeController,
                        label: 'Waktu Informasi',
                        icon: Icons.access_time,
                      ),
                    ),
                  ),
                  _buildTextField(
                    controller: descriptionController,
                    label: 'Deskripsi Informasi',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    label: const Text(
                      'Unggah Gambar Informasi',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                  ),
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.memory(_selectedImage!, height: 200),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveInformasi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C7566),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              'Simpan Informasi',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
