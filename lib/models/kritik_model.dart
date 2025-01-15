class KritikModel {
  final String id;
  final String stambuk;
  final String nama;
  final String kritik;
  final String createdAt;

  KritikModel({
    required this.id,
    required this.stambuk,
    required this.nama,
    required this.kritik,
    required this.createdAt,
  });

  factory KritikModel.fromJson(Map<String, dynamic> json) {
    return KritikModel(
      id: json['_id'], // Sesuaikan dengan nama field ID dari server
      stambuk: json['stambuk'],
      nama: json['nama'],
      kritik: json['kritik'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'stambuk': stambuk,
      'nama': nama,
      'kritik': kritik,
      'createdAt': createdAt,
    };
  }
}