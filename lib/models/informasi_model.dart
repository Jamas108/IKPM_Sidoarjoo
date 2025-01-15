import 'package:flutter/foundation.dart'; // Untuk deteksi platform

class InformasiModel {
  final String id;
  final String name;
  final String date;
  final String time;
  final String description;
  final String image;

  InformasiModel({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.description,
    required this.image,
  });

  /// Base URL untuk akses gambar
  static String get baseUrl {
    return kIsWeb ? 'http://localhost:5001' : 'http://10.0.2.2:5001';
  }

  // Factory untuk membuat instance dari JSON
  factory InformasiModel.fromJson(Map<String, dynamic> json) {
    final imagePath = json['image'] ?? '';
    return InformasiModel(
      id: json['_id'] ?? '', // Default ke string kosong jika null
      name: json['name'] ?? '', // Default ke string kosong
      date: json['date'] ?? '', // Default ke string kosong
      time: json['time'] ?? '', // Default ke string kosong
      description: json['description'] ?? '', // Default ke string kosong
      image: '$imagePath', // Gabungkan baseUrl dengan path gambar
    );
  }

  // Metode untuk mengonversi instance menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'date': date,
      'time': time,
      'description': description,
      'image': image,
    };
  }

  // Metode untuk membuat salinan instance dengan nilai tertentu yang diperbarui
  InformasiModel copyWith({
    String? id,
    String? name,
    String? date,
    String? time,
    String? description,
    String? image,
  }) {
    return InformasiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      time: time ?? this.time,
      description: description ?? this.description,
      image: image ?? this.image,
    );
  }

  // Metode untuk debugging
  @override
  String toString() {
    return 'InformasiModel(id: $id, name: $name, date: $date, time: $time, description: $description, image: $image)';
  }
}