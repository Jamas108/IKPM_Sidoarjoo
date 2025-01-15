import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:ikpm_sidoarjo/controllers/admin/alumni_controller.dart';
import 'package:ikpm_sidoarjo/models/alumni_model.dart';
import 'package:ikpm_sidoarjo/admin/layouts/sidebar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AlumniPageAdmin extends StatefulWidget {
  const AlumniPageAdmin({Key? key}) : super(key: key);

  @override
  _AlumniPageAdminState createState() => _AlumniPageAdminState();
}

class _AlumniPageAdminState extends State<AlumniPageAdmin> {
  final AlumniController _alumniController = AlumniController();
  List<AlumniModel> _alumniList = [];
  List<AlumniModel> _filteredAlumniList = [];
  String? _selectedYear;
  String? _selectedCampus;
  String? _selectedKecamatan;
  String _searchQuery = "";
  int _rowsPerPage = 5;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlumni();
  }

  Future<void> _loadAlumni() async {
    try {
      final alumni = await _alumniController.fetchAlumni();
      setState(() {
        _alumniList = alumni;
        _filteredAlumniList = List.from(alumni);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load alumni: $e')),
      );
    }
  }

  void _filterAlumni() {
    setState(() {
      _filteredAlumniList = _alumniList.where((alumni) {
        final matchesYear =
            _selectedYear == null || alumni.tahun == _selectedYear;
        final matchesCampus =
            _selectedCampus == null || alumni.kampusAsal == _selectedCampus;
        final matchesKecamatan = _selectedKecamatan == null ||
            alumni.kecamatan == _selectedKecamatan;
        final matchesSearch = alumni.namaAlumni
                ?.toLowerCase()
                .contains(_searchQuery.toLowerCase()) ??
            false;

        return matchesYear &&
            matchesCampus &&
            matchesKecamatan &&
            matchesSearch;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedYear = null;
      _selectedCampus = null;
      _selectedKecamatan = null;
      _searchQuery = "";
      _filteredAlumniList = List.from(_alumniList);
    });
  }

  void _showDeleteConfirmation(String stambuk) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content:
              const Text('Apakah Anda yakin ingin menghapus data alumni ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _deleteAlumni(stambuk); // Panggil fungsi hapus
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAlumni(String stambuk) async {
    final url = Uri.parse(
        'https://backend-ikpmsidoarjo.vercel.app/admin/alumni/$stambuk'); // Ganti dengan endpoint API Anda
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          _alumniList.removeWhere((alumni) => alumni.stambuk == stambuk);
          _filterAlumni();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alumni berhasil dihapus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus alumni')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showPasswordVerificationDialog(String stambuk) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verifikasi Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Masukkan Password Anda',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 23, 114, 110),
              ),
              onPressed: () async {
                final isValid =
                    await _validatePassword(passwordController.text);
                if (isValid) {
                  Navigator.of(context).pop(); // Tutup dialog
                  context.go('/admin/alumni/edit-password/$stambuk');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password salah'),
                    ),
                  );
                }
              },
              child: const Text('Lanjutkan', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _validatePassword(String password) async {
    // Validasi password akun yang sedang login
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('userPassword');
    return password == savedPassword;
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Kelola Alumni',
                          style: GoogleFonts.lato(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.go('/admin/alumni/create');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 23, 114, 110),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            'Tambah Alumni',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Search Bar
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Cari Nama",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _filterAlumni();
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Search & Filter Bar
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Filter Tahun"),
                            value: _selectedYear,
                            onChanged: (value) {
                              setState(() {
                                _selectedYear = value;
                                _filterAlumni();
                              });
                            },
                            items: _alumniList
                                .map((alumni) => alumni.tahun)
                                .toSet()
                                .toList()
                                .map((tahun) {
                              return DropdownMenuItem<String>(
                                value: tahun,
                                child: Text(tahun ?? '-'),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Filter Kampus Asal"),
                            value: _selectedCampus,
                            onChanged: (value) {
                              setState(() {
                                _selectedCampus = value;
                                _filterAlumni();
                              });
                            },
                            items: _alumniList
                                .map((alumni) => alumni.kampusAsal)
                                .toSet()
                                .toList()
                                .map((kampus) {
                              return DropdownMenuItem<String>(
                                value: kampus,
                                child: Text(kampus ?? '-'),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Filter Kecamatan"),
                            value: _selectedKecamatan,
                            onChanged: (value) {
                              setState(() {
                                _selectedKecamatan = value;
                                _filterAlumni();
                              });
                            },
                            items: _alumniList
                                .map((alumni) => alumni.kecamatan)
                                .toSet()
                                .toList()
                                .map((kecamatan) {
                              return DropdownMenuItem<String>(
                                value: kecamatan,
                                child: Text(kecamatan ?? '-'),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _resetFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 23, 114, 110),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Reset',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Data Table
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width,
                      ),
                      child: PaginatedDataTable(
                        header: const Text('Data Alumni'),
                        columns: const [
                          DataColumn(label: Text('No')),
                          DataColumn(label: Text('Nama')),
                          DataColumn(label: Text('Stambuk')),
                          DataColumn(label: Text('Kampus')),
                          DataColumn(label: Text('Kecamatan')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        source: _AlumniDataSource(
                          _filteredAlumniList,
                          context,
                          _showDeleteConfirmation,
                          _showPasswordVerificationDialog, // Callback hapus
                        ),
                        rowsPerPage: _rowsPerPage,
                        availableRowsPerPage: const [5, 10, 15],
                        onRowsPerPageChanged: (value) {
                          setState(() {
                            _rowsPerPage = value ?? 5;
                          });
                        },
                        columnSpacing: 16.0,
                        horizontalMargin: 16.0,
                        showCheckboxColumn: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _AlumniDataSource extends DataTableSource {
  final List<AlumniModel> alumniData;
  final BuildContext context;
  final Function(String stambuk) onDelete;
  final Function(String stambuk) onShowPasswordVerification;

  _AlumniDataSource(this.alumniData, this.context, this.onDelete,
      this.onShowPasswordVerification);

  @override
  DataRow? getRow(int index) {
    if (index >= alumniData.length) return null;

    final alumni = alumniData[index];
    return DataRow(
      cells: [
        DataCell(SizedBox(
          width: 50, // Kolom "No"
          child: Text((index + 1).toString()),
        )),
        DataCell(SizedBox(
          width: 320, // Kolom "Nama"
          child: Text(alumni.namaAlumni ?? '-'),
        )),
        DataCell(SizedBox(
          width: 100, // Kolom "Stambuk"
          child: Text(alumni.stambuk ?? '-'),
        )),
        DataCell(SizedBox(
          width: 480, // Kolom "Kampus"
          child: Text(alumni.kampusAsal ?? '-'),
        )),
        DataCell(SizedBox(
          width: 190, // Kolom "Kecamatan"
          child: Text(alumni.kecamatan ?? '-'),
        )),
        DataCell(SizedBox(
          width: 160, // Kolom "Aksi"
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.green),
                onPressed: () {
                  GoRouter.of(context)
                      .go('/admin/alumni/detail/${alumni.stambuk}');
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  GoRouter.of(context)
                      .go('/admin/alumni/edit/${alumni.stambuk}');
                },
              ),
              IconButton(
                icon: const Icon(Icons.lock, color: Colors.orange),
                onPressed: () {
                  onShowPasswordVerification(alumni.stambuk ?? '');
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  onDelete(alumni.stambuk ?? '');
                },
              ),
            ],
          ),
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => alumniData.length;

  @override
  int get selectedRowCount => 0;
}
