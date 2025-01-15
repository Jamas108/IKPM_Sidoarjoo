import 'package:flutter/foundation.dart'; // Untuk deteksi Web

class ParticipationsModel {
  final String id;
  final String userId;
  final String kegiatanId;


  ParticipationsModel({
    required this.id,
    required this.userId,
    required this.kegiatanId,
  });

  /// Base URL untuk akses gambar
  static String get baseUrl {
    return kIsWeb ? 'http://localhost:5001' : 'http://10.0.2.2:5001';
  }

  /// Factory untuk membuat `EventModel` dari JSON
  factory ParticipationsModel.fromJson(Map<String, dynamic> json) {
    return ParticipationsModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? 'Unknown User',
      kegiatanId: json['kegiatanId'] ?? 'Unknown Event', // Gabungkan baseUrl dengan nama file
    );
  }

  /// Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'kegiatanId': kegiatanId,
    };
  }
}