import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikpm_sidoarjo/controllers/admin/event_controller.dart';
import 'package:ikpm_sidoarjo/models/event_model.dart';

class EditEventPage extends StatefulWidget {
  final EventModel event;

  const EditEventPage({Key? key, required this.event}) : super(key: key);

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final EventController _eventController = EventController();
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
    // Inisialisasi controller dengan data dari event
    nameController.text = widget.event.name;
    dateController.text = widget.event.date;
    timeController.text = widget.event.time;
    locationController.text = widget.event.location;
    descriptionController.text = widget.event.description;
  }

  Future<void> _handlePickImage() async {
    final result = await _eventController.pickImage();
    if (result.isNotEmpty) {
      setState(() {
        _newPosterBytes = result['imageBytes'];
        _newPosterName = result['imageName'];
      });
    }
  }

  Future<void> _handleSelectDate() async {
    final selectedDate = await _eventController.selectDate(context);
    if (selectedDate != null) {
      setState(() {
        dateController.text = selectedDate;
      });
    }
  }

  Future<void> _handleSelectTime() async {
    final selectedTime = await _eventController.selectTime(context);
    if (selectedTime != null) {
      setState(() {
        timeController.text = selectedTime;
      });
    }
  }

  Future<void> _handleUpdateEvent() async {
    try {
      await _eventController.updateEvent(
        kegiatanId: widget.event.id,
        name: nameController.text,
        date: dateController.text,
        time: timeController.text,
        location: locationController.text,
        description: descriptionController.text,
        imageBytes: _newPosterBytes,
        imageName: _newPosterName,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event berhasil diperbarui')),
      );
      Navigator.pop(context); // Kembali ke halaman sebelumnya
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
        title: const Text('Edit Event'),
        backgroundColor: const Color(0xFF2C7566),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_newPosterBytes != null || widget.event.poster.isNotEmpty)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _newPosterBytes != null
                    ? Image.memory(_newPosterBytes!,
                        height: 300, width: double.infinity, fit: BoxFit.cover)
                    : Image.network(widget.event.poster,
                        height: 300, width: double.infinity, fit: BoxFit.cover),
              ),
            ElevatedButton.icon(
              onPressed: _handlePickImage,
              icon: const Icon(Icons.image, color: Colors.white),
              label: const Text('Pilih Poster Baru'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(height: 16),
            _buildTextField(nameController, 'Nama Event', Icons.event),
            GestureDetector(
              onTap: _handleSelectDate,
              child: AbsorbPointer(
                child:
                    _buildTextField(dateController, 'Tanggal Event', Icons.date_range),
              ),
            ),
            GestureDetector(
              onTap: _handleSelectTime,
              child: AbsorbPointer(
                child: _buildTextField(timeController, 'Waktu Event', Icons.access_time),
              ),
            ),
            _buildTextField(locationController, 'Lokasi Event', Icons.location_on),
            _buildTextField(descriptionController, 'Deskripsi Event', Icons.description,
                maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleUpdateEvent,
              child: const Text('Update Event'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C7566),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
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