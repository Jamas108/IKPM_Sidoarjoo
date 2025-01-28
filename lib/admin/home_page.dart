import 'package:flutter/material.dart';
import 'package:ikpm_sidoarjo/admin/layouts/sidebar.dart';
import 'package:ikpm_sidoarjo/controllers/admin/dashboard_controller.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({Key? key}) : super(key: key);

  @override
  _HomePageAdminState createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  late Future<Map<String, int>> _dashboardData;

  @override
  void initState() {
    super.initState();
    // Inisialisasi pemanggilan data dari controller
    _dashboardData = DashboardController().getDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              FutureBuilder<Map<String, int>>(
                future: _dashboardData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        // Mengatur jumlah kolom berdasarkan ukuran layar
                        int crossAxisCount = 4;
                        if (constraints.maxWidth < 600) {
                          crossAxisCount = 2; // 2 kolom untuk layar lebih kecil
                        }
                        if (constraints.maxWidth < 400) {
                          crossAxisCount =
                              1; // 1 kolom untuk layar sangat kecil
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 20.0,
                            mainAxisSpacing: 20.0,
                            childAspectRatio:
                                1.7, // Mengubah rasio untuk mencegah overflow
                          ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            switch (index) {
                              case 0:
                                return CardWidget(
                                  icon: Icons.person,
                                  count: data['alumni']!,
                                  label: 'Jumlah Alumni',
                                  color: Colors.orange,
                                );
                              case 1:
                                return CardWidget(
                                  icon: Icons.timer,
                                  count: data['kegiatan']!.toDouble(),
                                  label: 'Jumlah Kegiatan',
                                  color: Colors.blue,
                                );
                              case 2:
                                return CardWidget(
                                  icon: Icons.book,
                                  count: data['informasi']!,
                                  label: 'Jumlah Informasi',
                                  color: Colors.teal,
                                );
                              case 3:
                                return CardWidget(
                                  icon: Icons.comment,
                                  count: data['kritik']!,
                                  label: 'Jumlah Kritik dan Saran',
                                  color: Colors.pink,
                                );
                              default:
                                return Container();
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No Data Available'));
                  }
                },
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.grey[300]), // Divider untuk pemisah
              const SizedBox(height: 10),
              // Deskripsi Tugas Admin dalam card full width
              Container(
                width: double.infinity, // Memastikan lebar card penuh
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Deskripsi Tugas Admin',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                            '1. Admin dapat menambahkan, mengedit, melihat detail beserta menghapus data kegiatan.'),
                        SizedBox(height: 8),
                        Text(
                            '2. Admin dapat menambahkan, mengedit, melihat detail beserta menghapus data Informasi.'),
                        SizedBox(height: 8),
                        Text(
                            '3. Admin dapat menambahkan, mengedit, melihat detail, menghapus serta mengganti password akun alumni.'),
                        SizedBox(height: 8),
                        Text(
                            '4. Admin dapat melihat, menghapus dan menunduh format PDF peserta kegiatan.'),
                        SizedBox(height: 8),
                        Text(
                            '5. Admin dapat menambahkan komentar, mengedit komentar yang dimiliki, serta menghapus seluruh komentar pengguna yang di inginkan.'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final IconData icon;
  final dynamic count;
  final String label;
  final Color color;

  const CardWidget({
    Key? key,
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8, // Bayangan lebih besar
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)), // Sudut lebih melengkung
      color: Colors.white, // Card berwarna putih
      child: Container(
        padding: const EdgeInsets.all(20.0), // Padding lebih besar
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50, // Ukuran ikon lebih besar
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              '$count', // Tanpa simbol "$"
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style:
                  TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
