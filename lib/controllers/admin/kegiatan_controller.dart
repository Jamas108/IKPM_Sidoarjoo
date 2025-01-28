import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/event_model.dart';
import 'package:intl/intl.dart';

class EventController {
  final String baseUrl = 'https://backend-ikpmsidoarjo.vercel.app/kegiatans';

  // Fetch all events
  Future<List<EventModel>> fetchKegiatan() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => EventModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  // Delete an event and refresh list
  Future<List<EventModel>> deleteKegiatanAndRefresh(
      String kegiatanId, List<EventModel> events) async {
    final response = await http.delete(Uri.parse('$baseUrl/$kegiatanId'));
    if (response.statusCode == 200) {
      return events.where((event) => event.id != kegiatanId).toList();
    } else {
      throw Exception('Failed to delete event');
    }
  }

  // Search events by query
  List<EventModel> filterKegiatan(List<EventModel> events, String query) {
    if (query.isEmpty) {
      return events;
    }
    return events
        .where((event) =>
            event.name.toLowerCase().contains(query.toLowerCase()) ||
            event.location.toLowerCase().contains(query.toLowerCase()) ||
            event.date.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Add a new event
  Future<void> addKegiatan({
    required String name,
    required String date,
    required String time,
    required String location,
    required String description,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

    request.fields['name'] = name;
    request.fields['date'] = date;
    request.fields['time'] = time;
    request.fields['location'] = location;
    request.fields['description'] = description;

    if (imageBytes != null && imageName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'poster',
          imageBytes,
          filename: imageName,
        ),
      );
    }

    final response = await request.send();

    if (response.statusCode != 201) {
      throw Exception('Failed to add event');
    }
  }

  // Update an event
  Future<void> updateKegiatan({
    required String kegiatanId,
    required String name,
    required String date,
    required String time,
    required String location,
    required String description,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/$kegiatanId'));

    request.fields['name'] = name;
    request.fields['date'] = date;
    request.fields['time'] = time;
    request.fields['location'] = location;
    request.fields['description'] = description;

    if (imageBytes != null && imageName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'poster',
          imageBytes,
          filename: imageName,
        ),
      );
    }

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to update event');
    }
  }

  // Pick image file
  Future<Map<String, dynamic>> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      return {
        'imageBytes': file.bytes,
        'imageName': file.name,
      };
    }
    return {};
  }

  // Select a date
  Future<String?> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      return DateFormat('yyyy-MM-dd').format(picked);
    }
    return null;
  }

  // Select a time
  Future<String?> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      return picked.format(context);
    }
    return null;
  }

  // Delete an event and refresh list
}