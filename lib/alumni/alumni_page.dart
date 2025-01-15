import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/alumni_controller.dart';
import '../layouts/navbar_layout.dart';
import '../layouts/bottom_bar.dart';

class AlumniPage extends StatelessWidget {
  const AlumniPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AlumniController()..fetchAlumniData(),
      child: const AlumniPageContent(),
    );
  }
}

class AlumniPageContent extends StatelessWidget {
  const AlumniPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final alumniController = Provider.of<AlumniController>(context);

    return Scaffold(
      appBar: kIsWeb
          ? const Navbar()
          : AppBar(
              title: const Text("Halaman Alumni"),
              backgroundColor: const Color.fromARGB(255, 23, 114, 110),
            ),
      body: alumniController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (kIsWeb)
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 2,
                      child: Image.asset(
                        'assets/banneralumni.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: alumniController.searchController,
                      decoration: InputDecoration(
                        labelText: 'Cari Alumni',
                        hintText: 'Masukkan nama, stambuk, atau kecamatan...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: (value) => alumniController.filterAlumniData(),
                    ),
                  ),
                  // Filter Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        // Filter Tahun
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Filter Tahun"),
                            value: alumniController.selectedTahun,
                            onChanged: (value) {
                              alumniController.setTahunFilter(value);
                            },
                            items: alumniController.alumniData
                                .map((e) => e['tahun'])
                                .toSet()
                                .toList()
                                .map((tahun) {
                              return DropdownMenuItem<String>(
                                value: tahun.toString(),
                                child: Text(tahun.toString()),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Filter Kampus Asal
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Filter Kampus Asal"),
                            value: alumniController.selectedPondok,
                            onChanged: (value) {
                              alumniController.setPondokFilter(value);
                            },
                            items: alumniController.alumniData
                                .map((e) => e['kampus_asal'])
                                .toSet()
                                .toList()
                                .map((pondok) {
                              return DropdownMenuItem<String>(
                                value: pondok.toString(),
                                child: Text(pondok.toString()),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Filter Kecamatan
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Filter Kecamatan"),
                            value: alumniController.selectedKecamatan,
                            onChanged: (value) {
                              alumniController.setKecamatanFilter(value);
                            },
                            items: alumniController.alumniData
                                .map((e) => e['kecamatan'])
                                .toSet()
                                .toList()
                                .map((kecamatan) {
                              return DropdownMenuItem<String>(
                                value: kecamatan.toString(),
                                child: Text(kecamatan.toString()),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Reset Button
                        ElevatedButton.icon(
                          onPressed: () {
                            alumniController.resetFilters();
                          },
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text(
                            "Reset",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tabel Data Alumni
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: PaginatedDataTable(
                      header: const Text('Data Alumni'),
                      columns: const [
                        DataColumn(label: Text('No')),
                        DataColumn(label: Text('Stambuk')),
                        DataColumn(label: Text('Nama')),
                        DataColumn(label: Text('Kampus Asal')),
                        DataColumn(label: Text('Kecamatan')),
                        DataColumn(label: Text('Action')),
                      ],
                      source: _AlumniDataSource(
                        alumniController.filteredAlumniData,
                        context,
                      ),
                      rowsPerPage: alumniController.rowsPerPage,
                      availableRowsPerPage: const [5, 10, 15],
                      onRowsPerPageChanged: (value) {
                        alumniController.setRowsPerPage(value ?? 5);
                      },
                      showCheckboxColumn: false,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Footer
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF2C7566),
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: const Center(
                      child: Text(
                        "© 2025 IKPM Sidoarjo. All Rights Reserved.",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: kIsWeb
          ? null
          : BottomBar(
              currentIndex: 1,
              onTap: (index) {},
            ),
    );
  }
}

class _AlumniDataSource extends DataTableSource {
  final List<dynamic> alumniData;
  final BuildContext context;

  _AlumniDataSource(this.alumniData, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= alumniData.length) return null;

    final alumni = alumniData[index];
    return DataRow(cells: [
      DataCell(Text((index + 1).toString())),
      DataCell(Text(alumni['stambuk'])),
      DataCell(Text(alumni['nama_alumni'])),
      DataCell(Text(alumni['kampus_asal'])),
      DataCell(Text(alumni['kecamatan'])),
      DataCell(
        IconButton(
          icon: const Icon(Icons.info),
          tooltip: 'Lihat Detail',
          onPressed: () {
            GoRouter.of(context).go('/alumni/${alumni['stambuk']}');
          },
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => alumniData.length;

  @override
  int get selectedRowCount => 0;
}
