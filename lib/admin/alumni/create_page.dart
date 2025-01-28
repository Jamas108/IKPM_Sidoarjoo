import 'package:flutter/material.dart';
import 'package:ikpm_sidoarjo/controllers/admin/alumni_controller.dart';

class AddAlumniPage extends StatefulWidget {
  const AddAlumniPage({Key? key}) : super(key: key);

  @override
  _AddAlumniPageState createState() => _AddAlumniPageState();
}

class _AddAlumniPageState extends State<AddAlumniPage> {
  final _formKey = GlobalKey<FormState>();
  final AlumniController _alumniController = AlumniController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _stambukController = TextEditingController();
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
  final TextEditingController _passwordController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final alumniData = {
      'nama': _namaController.text,
      'stambuk': _stambukController.text,
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
      'password': _passwordController.text,
      'role_id': 2,
    };

    try {
      final isSuccess = await _alumniController.createAlumni(alumniData);

      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data alumni berhasil ditambahkan!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan data: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Alumni'),
        backgroundColor: const Color.fromARGB(255, 23, 114, 110),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        color: const Color(0xFFF6F7FB),
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Text(
                    'Tambah Data Alumni',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                    controller: _stambukController,
                    label: 'Stambuk',
                    isRequired: true,
                  ),
                  _buildTextField(
                    controller: _tahunController,
                    label: 'Tahun Lulus',
                    isRequired: true,
                    inputType: TextInputType.number, // Hanya angka
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tahun Lulus wajib diisi';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Tahun Lulus harus berupa angka';
                      }
                      return null;
                    },
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
                    inputType: TextInputType.phone, // Input type untuk telepon
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'No. Telepon wajib diisi';
                      }
                      if (int.tryParse(value) == null) {
                        return 'No. Telepon harus berupa angka';
                      }
                      return null;
                    },
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
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    isRequired: true,
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 23, 114, 110),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Simpan',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white),
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
    bool obscureText = false,
    TextInputType? inputType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
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
        obscureText: obscureText,
        validator: validator ??
            (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return '$label wajib diisi';
              }
              return null;
            },
      ),
    );
  }
}