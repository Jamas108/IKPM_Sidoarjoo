class CommentModel {
  final String id;
  final String informasiId;
  final String comment;
  final String stambuk;
  final String nama;
  final String createdAt;
  final String updatedAt;

  CommentModel({
    required this.id,
    required this.informasiId,
    required this.comment,
    required this.stambuk,
    required this.nama,
    required this.createdAt,
    required this.updatedAt,
  });

  // Konversi dari JSON ke CommentModel
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'] ?? '',
      informasiId: json['informasiId'] ?? '',
      comment: json['comment'] ?? '',
      stambuk: json['stambuk'] ?? '',
      nama: json['nama'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  // Konversi dari CommentModel ke JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'informasiId': informasiId,
      'comment': comment,
      'stambuk': stambuk,
      'nama': nama,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}