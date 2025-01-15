import 'package:flutter/foundation.dart'; // Untuk deteksi Web// Untuk deteksi Web

class EventModel {
  final String id;
  final String name;
  final String date;
  final String time;
  final String location;
  final String description;
  final String poster;

  EventModel({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.poster,
  });

  /// Base URL untuk akses gambar
  static String get baseUrl {
    return kIsWeb ? 'http://localhost:5001' : 'http://10.0.2.2:5001';
  }

  /// Factory untuk membuat `EventModel` dari JSON
  factory EventModel.fromJson(Map<String, dynamic> json) {
    final posterPath = json['poster'] ?? '';
    return EventModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Event',
      date: json['date'] ?? '2023-01-01',
      time: json['time'] ?? '00:00',
      location: json['location'] ?? 'Unknown Location',
      description: json['description'] ?? 'No description available.',
      poster: '$posterPath', // Gabungkan baseUrl dengan nama file
    );
  }

  /// Konversi ke JSON
  // Map<String, dynamic> toJson() {
  //   return {
  //     '_id': id,
  //     'name': name,
  //     'date': date,
  //     'time': time,
  //     'location': location,
  //     'description': description,
  //     'poster': poster,
  //   };
  // }
}
