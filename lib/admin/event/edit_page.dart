import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikpm_sidoarjo/controllers/admin/kegiatan_controller.dart';
import 'package:ikpm_sidoarjo/models/event_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class EditEventPage extends StatefulWidget {
  final EventModel event;

  const EditEventPage({Key? key, required this.event}) : super(key: key);

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final EventController _eventController = EventController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Uint8List? _newPosterBytes;
  String? _newPosterName;
  String? _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the current event data
    nameController.text = widget.event.name;
    dateController.text = widget.event.date;
    timeController.text = widget.event.time;
    locationController.text = widget.event.location;
    descriptionController.text = widget.event.description;
    _selectedStatus = widget.event.status; // Menyimpan status sebelumnya
  }

  // Pilih gambar dari file picker
  Future<void> _handlePickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _newPosterBytes = result.files.first.bytes;
        _newPosterName = result.files.first.name;
      });
    }
  }

  // Pilih tanggal dengan Date Picker
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

  // Pilih waktu dengan Time Picker
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

  // Simpan perubahan event
  Future<void> _handleUpdateKegiatan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; // Aktifkan indikator loading
    });

    try {
      await _eventController.updateKegiatan(
        kegiatanId: widget.event.id,
        name: nameController.text,
        date: dateController.text,
        time: timeController.text,
        status: _selectedStatus ??
            widget.event.status, // Gunakan status sebelumnya jika tidak dipilih
        location: locationController.text,
        description: descriptionController.text,
        imageBytes: _newPosterBytes,
        imageName: _newPosterName,
      );

      final updatedEvent = EventModel(
        id: widget.event.id,
        name: nameController.text,
        date: dateController.text,
        time: timeController.text,
        status: _selectedStatus ?? widget.event.status,
        location: locationController.text,
        description: descriptionController.text,
        poster: widget.event.poster,
      );

      Navigator.pop(context, updatedEvent);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
          'Edit Kegiatan',
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 23, 114, 110),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tampilkan gambar poster jika ada
                if (_newPosterBytes != null || widget.event.poster.isNotEmpty)
                  Center(
                    child: _newPosterBytes != null
                        ? Image.memory(
                            _newPosterBytes!,
                            height: 250,
                            width: 250,
                            fit: BoxFit.contain,
                          )
                        : Image.network(
                            widget.event.poster,
                            height: 250,
                            width: 250,
                            fit: BoxFit.contain,
                          ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _handlePickImage,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text(
                    'Pilih Poster Baru',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                          nameController, 'Nama Kegiatan', Icons.event),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: _buildTextField(dateController,
                              'Tanggal Kegiatan', Icons.date_range),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _selectTime(context),
                        child: AbsorbPointer(
                          child: _buildTextField(timeController,
                              'Waktu Kegiatan', Icons.access_time),
                        ),
                      ),
                      _buildTextField(locationController, 'Lokasi Kegiatan',
                          Icons.location_on),
                      _buildTextField(descriptionController,
                          'Deskripsi Kegiatan', Icons.description,
                          maxLines: 3),

                      const SizedBox(height: 10),

                      // Dropdown untuk memilih Status
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: "Status Kegiatan",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.check_circle),
                        ),
                        items: [
                          'Akan Datang',
                          'Berjalan',
                          'Selesai',
                          'Disembunyikan'
                        ]
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleUpdateKegiatan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C7566),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text(
                                  'Perbarui Kegiatan',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                        ),
                      )
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

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? '$label wajib diisi' : null,
      ),
    );
  }
}
