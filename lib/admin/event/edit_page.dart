import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikpm_sidoarjo/controllers/admin/kegiatan_controller.dart';
import 'package:ikpm_sidoarjo/models/event_model.dart';
import 'package:file_picker/file_picker.dart';

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

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the current event data
    nameController.text = widget.event.name;
    dateController.text = widget.event.date;
    timeController.text = widget.event.time;
    locationController.text = widget.event.location;
    descriptionController.text = widget.event.description;
  }

  // Method for selecting a new image (similar to the EditInformasiPage)
  Future<void> _handlePickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _newPosterBytes = result.files.first.bytes;
        _newPosterName = result.files.first.name;
      });
    }
  }

  // Method for updating event data
  Future<void> _handleUpdateKegiatan() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _eventController.updateKegiatan(
        kegiatanId: widget.event.id,
        name: nameController.text,
        date: dateController.text,
        time: timeController.text,
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
        location: locationController.text,
        description: descriptionController.text,
        poster:
            widget.event.poster, // keep the same poster or change if updated
      );

      Navigator.pop(context, updatedEvent);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event berhasil diperbarui')),
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
                // Display the poster image if available
                // Image Display with proper alignment and smaller size
                if (_newPosterBytes != null || widget.event.poster.isNotEmpty)
                  Center(
                    child: _newPosterBytes != null
                        ? Image.memory(
                            _newPosterBytes!,
                            height: 250, // Reduced size
                            width: 250, // Reduced size
                            fit: BoxFit
                                .contain, // Ensure the whole image is shown
                          )
                        : Image.network(
                            widget.event.poster,
                            height: 250, // Reduced size
                            width: 250, // Reduced size
                            fit: BoxFit
                                .contain, // Ensure the whole image is shown
                          ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _handlePickImage,
                  child: const Text(
                    'Pilih Poster Baru',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // Warna teks diubah menjadi putih
                    ),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                          nameController, 'Nama Event', Icons.event),
                      _buildTextField(
                          dateController, 'Tanggal Event', Icons.date_range),
                      _buildTextField(
                          timeController, 'Waktu Event', Icons.access_time),
                      _buildTextField(locationController, 'Lokasi Event',
                          Icons.location_on),
                      _buildTextField(descriptionController, 'Deskripsi Event',
                          Icons.description,
                          maxLines: 3),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _handleUpdateKegiatan,
                        child: const Text(
                          'Edit Kegiatan',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Colors.white, // Warna teks diubah menjadi putih
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C7566),
                          padding: const EdgeInsets.symmetric(vertical: 15),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
