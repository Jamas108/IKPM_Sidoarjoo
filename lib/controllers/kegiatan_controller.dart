  import 'dart:convert';
import 'package:flutter/foundation.dart'; // Untuk deteksi platform
import 'package:http/http.dart' as http;
import '../models/event_model.dart';

class EventController {
  // URL untuk endpoint API event
  late final String apiUrl;
  late final String _baseUrl;
  List<EventModel> _cachedEventList = [];

  EventController() {
    // Deteksi platform
    if (kIsWeb) {
      // Gunakan localhost untuk Web
      apiUrl = 'https://backend-ikpmsidoarjo.vercel.app/kegiatans';
      _baseUrl = 'https://backend-ikpmsidoarjo.vercel.app';
    } else {
      // Gunakan 10.0.2.2 untuk Android Emulator
      apiUrl = 'https://backend-ikpmsidoarjo.vercel.app/kegiatans';
      _baseUrl = 'https://backend-ikpmsidoarjo.vercel.app';
    }
  }

Future<List<EventModel>> fetchKegiatan() async {
  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      // Filter kegiatan dengan status "Disembunyikan"
      _cachedEventList = jsonData
          .map((event) => EventModel.fromJson(event))
          .where((event) => event.status != 'Disembunyikan')
          .toList();
      return _cachedEventList;
    } else {
      throw Exception(
          'Failed to load events. Status Code: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error fetching events: $error');
  }
}

  Future<EventModel> fetchEventById(String id) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/$id'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Konversi JSON menjadi EventModel
        return EventModel.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to load event. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching event by ID: $error');
      throw Exception('Error fetching event by ID: $error');
    }
  }

  // Fungsi untuk menambahkan event baru
  Future<void> addEvent(EventModel event, String filePath) async {
    try {
      final uri = Uri.parse(apiUrl);
      final request = http.MultipartRequest('POST', uri);

      // Tambahkan data event ke request
      request.fields['name'] = event.name;
      request.fields['date'] = event.date;
      request.fields['time'] = event.time;
      request.fields['location'] = event.location;
      request.fields['description'] = event.description;

      // Tambahkan poster jika ada
      if (filePath.isNotEmpty) {
        final poster = await http.MultipartFile.fromPath('poster', filePath);
        request.files.add(poster);
      }

      final response = await request.send();

      if (response.statusCode != 201) {
        throw Exception(
            'Failed to add event. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error adding event: $error');
      throw Exception('Error adding event: $error');
    }
  }

  // Fungsi untuk memperbarui event berdasarkan ID
  Future<void> updateEvent(
      String kegiatanId, EventModel event, String? filePath) async {
    try {
      final uri = Uri.parse('$apiUrl/$kegiatanId');
      final request = http.MultipartRequest('PUT', uri);

      // Tambahkan data event ke request
      request.fields['name'] = event.name;
      request.fields['date'] = event.date;
      request.fields['time'] = event.time;
      request.fields['location'] = event.location;
      request.fields['description'] = event.description;

      // Tambahkan poster jika ada
      if (filePath != null && filePath.isNotEmpty) {
        final poster = await http.MultipartFile.fromPath('poster', filePath);
        request.files.add(poster);
      }

      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update event. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating event: $error');
      throw Exception('Error updating event: $error');
    }
  }

  // Fungsi untuk menghapus event berdasarkan ID
  Future<void> deleteEvent(String kegiatanId) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$kegiatanId'));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete event. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting event: $error');
      throw Exception('Error deleting event: $error');
    }
  }

  Future<void> registerForEvent({
    required String userId,
    required String kegiatanId,
  }) async {
    final url = Uri.parse('$_baseUrl/participate');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'kegiatanId': kegiatanId,
        }),
      );

      if (response.statusCode != 201) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to register for the event');
      }
    } catch (error) {
      throw Exception('Error registering for event: $error');
    }
  }

  // Future<List<EventModel>> fetchParticipations(String userId) async {
  //   final url = Uri.parse('$_baseUrl/historyevent/$userId');
  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       final List<dynamic> jsonData = json.decode(response.body);

  //       // Map JSON data to EventModel
  //       return jsonData.map((event) => EventModel.fromJson(event)).toList();
  //     } else if (response.statusCode == 404) {
  //       return []; // Tidak ada partisipasi
  //     } else {
  //       throw Exception('Failed to load participations');
  //     }
  //   } catch (error) {
  //     throw Exception('Error fetching participations: $error');
  //   }
  // }

  Future<List<String>> fetchParticipationKegiatanIds(String stambuk) async {
    final url = Uri.parse('$_baseUrl/historyevent/$stambuk');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((id) => id as String).toList();
    } else {
      throw Exception('Failed to fetch participation IDs');
    }
  }

  Future<List<EventModel>> fetchRiwayatKegiatan(String userId) async {
    final url = Uri.parse('$_baseUrl/historyevent/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((event) => EventModel.fromJson(event)).toList();
    } else {
      throw Exception(
          'Failed to fetch participated events. Status code: ${response.statusCode}');
    }
  }

  List<EventModel> filterKegiatan(String query) {
    return _cachedEventList.where((event) {
      return event.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
