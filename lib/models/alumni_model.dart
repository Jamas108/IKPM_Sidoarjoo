class AlumniModel {
  final int no;
  final String? tahun;
  final String? stambuk;
  final String? namaAlumni;
  final String? kampusAsal;
  final String? kecamatan;
  final String? alamat;
  final String? noTelepon;
  final String? pasangan;
  final String? namaLaqob;
  final String? pekerjaan;
  final String? ttl;
  final String? instansi;

  AlumniModel({
    required this.no,
    this.tahun,
    this.stambuk,
    this.namaAlumni,
    this.kampusAsal,
    this.kecamatan,
    this.alamat,
    this.noTelepon,
    this.pasangan,
    this.namaLaqob,
    this.pekerjaan,
    this.ttl,
    this.instansi,
  });

  factory AlumniModel.fromJson(Map<String, dynamic> json) {
    return AlumniModel(
      no: json['no'] ?? 0,
      tahun: json['tahun'],
      stambuk: json['stambuk'],
      namaAlumni: json['nama_alumni'],
      kampusAsal: json['kampus_asal'],
      kecamatan: json['kecamatan'],
      alamat: json['alamat'],
      noTelepon: json['no_telepon'],
      pasangan: json['pasangan'],
      namaLaqob: json['nama_laqob'],
      pekerjaan: json['pekerjaan'],
      ttl: json['ttl'],
      instansi: json['instansi'],
    );
  }
}