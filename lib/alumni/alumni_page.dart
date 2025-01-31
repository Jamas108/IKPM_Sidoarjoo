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
              title: const Text(
                "Daftar Alumni",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color.fromARGB(255, 23, 114, 110),
            ),
      body: alumniController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Banner
                  if (kIsWeb)
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 2,
                      child: Image.asset(
                        'assets/banneralumni.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Input Pencarian
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

                  // Filter Dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Filter Tahun"),
                            value: alumniController.selectedTahun,
                            onChanged: (value) {
                              alumniController.setTahunFilter(value);
                            },
                            items: alumniController.sortedTahunList
                                .map((tahun) => DropdownMenuItem<String>(
                                      value: tahun,
                                      child: Text(tahun),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Filter Kampus Asal"),
                            value: alumniController.selectedPondok,
                            onChanged: (value) {
                              alumniController.setPondokFilter(value);
                            },
                            items: alumniController.sortedPondokList
                                .map((pondok) => DropdownMenuItem<String>(
                                      value: pondok,
                                      child: Text(pondok),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Filter Kecamatan"),
                            value: alumniController.selectedKecamatan,
                            onChanged: (value) {
                              alumniController.setKecamatanFilter(value);
                            },
                            items: alumniController.sortedKecamatanList
                                .map((kecamatan) => DropdownMenuItem<String>(
                                      value: kecamatan,
                                      child: Text(kecamatan),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
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

                  // **Daftar Alumni**
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: alumniController.filteredAlumniData.isEmpty
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4, // Biar tidak terlalu ke atas
                            child: const Center(
                              child: Text(
                                "Data alumni tidak ditemukan.",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(), // Agar tidak ada scroll dalam list
                            itemCount: alumniController.filteredAlumniData.length,
                            itemBuilder: (context, index) {
                              final alumni = alumniController.filteredAlumniData[index];
                              return alumni != null ? _buildAlumniListCard(alumni, context) : const SizedBox();
                            },
                          ),
                  ),

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

  Widget _buildAlumniListCard(Map<String, dynamic>? alumni, BuildContext context) {
    if (alumni == null) {
      return const SizedBox();
    }

    final String nama = alumni['nama_alumni'] ?? "Tidak Ada Nama";
    final String stambuk = alumni['stambuk']?.toString() ?? "Tidak Ada Stambuk";
    final String kampus = alumni['kampus_asal'] ?? "Tidak Ada Kampus";
    final String kecamatan = alumni['kecamatan'] ?? "Tidak Ada Kecamatan";

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal,
          radius: 25,
          child: Text(
            nama.isNotEmpty ? nama[0] : "?",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          nama,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          kampus,
          style: const TextStyle(color: Colors.teal, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: Colors.teal),
          onPressed: () {
            if (alumni['stambuk'] != null) {
              GoRouter.of(context).go('/alumni/${alumni['stambuk']}');
            }
          },
        ),
      ),
    );
  }
}