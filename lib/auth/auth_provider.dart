import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  // Status login dan data pengguna
  bool _isLoggedIn = false;
  String? _userStambuk;
  String? _userNama;
  String? _userTahun;
  String? _userKampusAsal;
  String? _userAlamat;
  String? _userNoTelepon;
  String? _userPasangan;
  String? _userPekerjaan;
  String? _userNamaLaqob;
  String? _userTtl;
  String? _userKecamatan;
  String? _userInstansi;
  String? _userPassword;
  int? _roleId;

  // Data yang disembunyikan
  List<String> _hiddenFields = [];

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get userStambuk => _userStambuk;
  String? get userNama => _userNama;
  String? get userTahun => _userTahun;
  String? get userKampusAsal => _userKampusAsal;
  String? get userAlamat => _userAlamat;
  String? get userNoTelepon => _userNoTelepon;
  String? get userPasangan => _userPasangan;
  String? get userPekerjaan => _userPekerjaan;
  String? get userNamaLaqob => _userNamaLaqob;
  String? get userTtl => _userTtl;
  String? get userKecamatan => _userKecamatan;
  String? get userInstansi => _userInstansi;
  String? get userPassword => _userPassword;
  int? get roleId => _roleId;
  List<String> get hiddenFields => _hiddenFields;

  // Login
  Future<void> login(
    String stambuk,
    String nama,
    String tahun,
    String kampusAsal,
    String alamat,
    String noTelepon,
    String pasangan,
    String pekerjaan,
    String namaLaqob,
    String ttl,
    String kecamatan,
    String instansi,
    String password,
    int roleId,
  ) async {
    _isLoggedIn = true;
    _userStambuk = stambuk;
    _userNama = nama;
    _userTahun = tahun;
    _userKampusAsal = kampusAsal;
    _userAlamat = alamat;
    _userNoTelepon = noTelepon;
    _userPasangan = pasangan;
    _userPekerjaan = pekerjaan;
    _userNamaLaqob = namaLaqob;
    _userTtl = ttl;
    _userKecamatan = kecamatan;
    _userInstansi = instansi;
    _userPassword = password;
    _roleId = roleId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userStambuk', stambuk);
    await prefs.setString('userNama', nama);
    await prefs.setString('userTahun', tahun);
    await prefs.setString('userKampusAsal', kampusAsal);
    await prefs.setString('userAlamat', alamat);
    await prefs.setString('userNoTelepon', noTelepon);
    await prefs.setString('userPasangan', pasangan);
    await prefs.setString('userPekerjaan', pekerjaan);
    await prefs.setString('userNamaLaqob', namaLaqob);
    await prefs.setString('userTtl', ttl);
    await prefs.setString('userKecamatan', kecamatan);
    await prefs.setString('userInstansi', instansi);
    await prefs.setString('userPassword', password);
    await prefs.setInt('roleId', roleId);

    // Muat data hidden fields
    _hiddenFields = prefs.getStringList('hiddenFields_$stambuk') ?? [];

    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    _isLoggedIn = false;
    _userStambuk = null;
    _userNama = null;
    _userTahun = null;
    _userKampusAsal = null;
    _userAlamat = null;
    _userNoTelepon = null;
    _userPasangan = null;
    _userPekerjaan = null;
    _userNamaLaqob = null;
    _userTtl = null;
    _userKecamatan = null;
    _userInstansi = null;
    _userPassword = null;
    _roleId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  // Muat sesi pengguna
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userStambuk = prefs.getString('userStambuk');
    _userNama = prefs.getString('userNama');
    _userTahun = prefs.getString('userTahun');
    _userKampusAsal = prefs.getString('userKampusAsal');
    _userAlamat = prefs.getString('userAlamat');
    _userNoTelepon = prefs.getString('userNoTelepon');
    _userPasangan = prefs.getString('userPasangan');
    _userPekerjaan = prefs.getString('userPekerjaan');
    _userNamaLaqob = prefs.getString('userNamaLaqob');
    _userTtl = prefs.getString('userTtl');
    _userKecamatan = prefs.getString('userKecamatan');
    _userInstansi = prefs.getString('userInstansi');
    _userPassword = prefs.getString('userPassword');
    _roleId = prefs.getInt('roleId');

    // Muat data hidden fields
    _hiddenFields = prefs.getStringList('hiddenFields_$_userStambuk') ?? [];

    notifyListeners();
  }

  // Perbarui hidden fields
  Future<void> updateHiddenFields(List<String> fields) async {
    _hiddenFields = fields;

    final prefs = await SharedPreferences.getInstance();
    if (_userStambuk != null) {
      await prefs.setStringList('hiddenFields_$_userStambuk', fields);
    }

    notifyListeners();
  }

  // Update profil pengguna
  Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    _userNama = updatedData['nama'] ?? _userNama;
    _userTahun = updatedData['tahun'] ?? _userTahun;
    _userKampusAsal = updatedData['kampusAsal'] ?? _userKampusAsal;
    _userAlamat = updatedData['alamat'] ?? _userAlamat;
    _userNoTelepon = updatedData['noTelepon'] ?? _userNoTelepon;
    _userPasangan = updatedData['pasangan'] ?? _userPasangan;
    _userPekerjaan = updatedData['pekerjaan'] ?? _userPekerjaan;
    _userNamaLaqob = updatedData['namaLaqob'] ?? _userNamaLaqob;
    _userTtl = updatedData['ttl'] ?? _userTtl;
    _userKecamatan = updatedData['kecamatan'] ?? _userKecamatan;
    _userInstansi = updatedData['instansi'] ?? _userInstansi;

    // Simpan ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    if (_userStambuk != null) {
      await prefs.setString('userNama', _userNama!);
      await prefs.setString('userTahun', _userTahun!);
      await prefs.setString('userKampusAsal', _userKampusAsal!);
      await prefs.setString('userAlamat', _userAlamat!);
      await prefs.setString('userNoTelepon', _userNoTelepon!);
      await prefs.setString('userPasangan', _userPasangan!);
      await prefs.setString('userPekerjaan', _userPekerjaan!);
      await prefs.setString('userNamaLaqob', _userNamaLaqob!);
      await prefs.setString('userTtl', _userTtl!);
      await prefs.setString('userKecamatan', _userKecamatan!);
      await prefs.setString('userInstansi', _userInstansi!);
    }

    notifyListeners(); // Memberitahu UI bahwa ada data yang berubah
  }
}
