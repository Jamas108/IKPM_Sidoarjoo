import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ikpm_sidoarjo/controllers/admin/alumni_controller.dart';

class EditAlumniPage extends StatefulWidget {
  final String stambuk; // ID atau Stambuk alumni
  const EditAlumniPage({Key? key, required this.stambuk}) : super(key: key);

  @override
  _EditAlumniPageState createState() => _EditAlumniPageState();
}

class _EditAlumniPageState extends State<EditAlumniPage> {
  final AlumniController _alumniController = AlumniController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tahunController = TextEditingController();
  final TextEditingController _kampusController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noTeleponController = TextEditingController();
  final TextEditingController _pasanganController = TextEditingController();
  final TextEditingController _pekerjaanController = TextEditingController();
  final TextEditingController _namaLaqobController = TextEditingController();
  final TextEditingController _ttlController = TextEditingController();
  final TextEditingController _kecamatanController = TextEditingController();
  final TextEditingController _instansiController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlumniById();
  }

  Future<void> _loadAlumniById() async {
    try {
      final alumni = await _alumniController.loadAlumniById(widget.stambuk);
      setState(() {
        _namaController.text = alumni['nama'] ?? '';
        _tahunController.text = alumni['tahun'] ?? '';
        _kampusController.text = alumni['kampus_asal'] ?? '';
        _alamatController.text = alumni['alamat'] ?? '';
        _noTeleponController.text = alumni['no_telepon'] ?? '';
        _pasanganController.text = alumni['pasangan'] ?? '';
        _pekerjaanController.text = alumni['pekerjaan'] ?? '';
        _namaLaqobController.text = alumni['nama_laqob'] ?? '';
        _ttlController.text = alumni['ttl'] ?? '';
        _kecamatanController.text = alumni['kecamatan'] ?? '';
        _instansiController.text = alumni['instansi'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _updateAlumni() async {
    if (_formKey.currentState!.validate()) {
      final alumniData = {
        'nama': _namaController.text,
        'tahun': _tahunController.text,
        'kampus_asal': _kampusController.text,
        'alamat': _alamatController.text,
        'no_telepon': _noTeleponController.text,
        'pasangan': _pasanganController.text,
        'pekerjaan': _pekerjaanController.text,
        'nama_laqob': _namaLaqobController.text,
        'ttl': _ttlController.text,
        'kecamatan': _kecamatanController.text,
        'instansi': _instansiController.text,
      };

      try {
        await _alumniController.updateAlumni(widget.stambuk, alumniData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data alumni berhasil diperbarui!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Alumni'),
        backgroundColor: const Color.fromARGB(255, 23, 114, 110),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: const Color(0xFFF6F7FB),
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Text(
                          'Edit Data Alumni',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _namaController,
                          label: 'Nama Alumni',
                          isRequired: true,
                        ),
                        _buildTextField(
                          controller: _tahunController,
                          label: 'Tahun Lulus',
                          isRequired: true,
                        ),
                        _buildTextField(
                          controller: _kampusController,
                          label: 'Kampus Asal',
                          isRequired: true,
                        ),
                        _buildTextField(
                          controller: _alamatController,
                          label: 'Alamat',
                          isRequired: true,
                        ),
                        _buildTextField(
                          controller: _noTeleponController,
                          label: 'No. Telepon',
                          isRequired: true,
                        ),
                        _buildTextField(
                          controller: _pasanganController,
                          label: 'Pasangan',
                          isRequired: false,
                        ),
                        _buildTextField(
                          controller: _pekerjaanController,
                          label: 'Pekerjaan',
                          isRequired: true,
                        ),
                        _buildTextField(
                          controller: _namaLaqobController,
                          label: 'Nama Laqob',
                          isRequired: false,
                        ),
                        _buildTextField(
                          controller: _ttlController,
                          label: 'Tempat, Tanggal Lahir',
                          isRequired: true,
                        ),
                        _buildTextField(
                          controller: _kecamatanController,
                          label: 'Kecamatan',
                          isRequired: true,
                        ),
                        _buildTextField(
                          controller: _instansiController,
                          label: 'Instansi',
                          isRequired: false,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _updateAlumni,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 23, 114, 110),
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            'Simpan Perubahan',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
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
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 23, 114, 110)),
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label wajib diisi';
          }
          return null;
        },
      ),
    );
  }
}
