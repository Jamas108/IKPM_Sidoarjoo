import 'package:flutter/foundation.dart'; // Untuk mendeteksi Web
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layouts/navbar_layout.dart'; // Navbar untuk Web
import '../layouts/bottom_bar.dart'; // BottomBar untuk Android

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollPosition = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Deteksi apakah platform adalah Web
    final bool isWeb = kIsWeb;

    return Scaffold(
      appBar: isWeb
          ? const Navbar() // Gunakan Navbar untuk Web
          : AppBar(
              title: const Text("Halaman Home"),
              backgroundColor: const Color.fromARGB(255, 23, 114, 110),
            ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Banner Full Height dengan Background Gambar
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height, // Full height
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/ikpmsidoarjobanner.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.5), // Overlay gelap untuk teks
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "SELAMAT DATANG DI IKPM SIDOARJO",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Berisi tentang sekumpulan informasi tentang alumni, kegiatan serta berita tentang Keluarga IKPM Cabang Sidoarjo.\nSemoga bermanfaat dan menambah wawasan anda :)",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Tambahkan navigasi ke halaman lain
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFFFF), // Putih
                            foregroundColor: const Color(0xFF2C7566), // Hijau teks
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: const Text("Login"),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Header Card Section dengan Animasi
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _scrollPosition > 100 ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: const Text(
                  "MENU IKPM SIDOARJO",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            // Card Section
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _scrollPosition > 200 ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isWeb ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: const [
                    _FeatureCard(
                      icon: Icons.desktop_mac,
                      title: "Data Alumni",
                    ),
                    _FeatureCard(
                      icon: Icons.event,
                      title: "Agenda Kegiatan",
                    ),
                    _FeatureCard(
                      icon: Icons.newspaper,
                      title: "Berita Terkini",
                    ),
                    _FeatureCard(
                      icon: Icons.contact_page,
                      title: "Kontak Kami",
                    ),
                  ],
                ),
              ),
            ),
            // Statistik Section
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _scrollPosition > 400 ? 1 : 0,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _StatisticCard(title: "Alumni", count: 1200),
                        _StatisticCard(title: "Kegiatan", count: 45),
                        _StatisticCard(title: "Berita", count: 30),
                      ],
                    ),
                  ),
                  // Header "TENTANG IKPM SIDOARJO"
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "TENTANG IKPM SIDOARJO",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Deskripsi di bawah header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Website ini dibuat untuk memberikan informasi terkait data alumni, kegiatan, serta berita terkini yang berhubungan dengan IKPM Sidoarjo. Kami berharap website ini menjadi sarana yang bermanfaat untuk Anda.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  // Header "KONTAK KAMI"
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "KONTAK KAMI",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Card Kontak Kami
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isWeb ? 4 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      children: const [
                        _FeatureCard(
                          icon: Icons.phone,
                          title: "Telepon",
                        ),
                        _FeatureCard(
                          icon: Icons.call,
                          title: "WhatsApp",
                        ),
                        _FeatureCard(
                          icon: Icons.camera,
                          title: "Instagram",
                        ),
                        _FeatureCard(
                          icon: Icons.facebook,
                          title: "Facebook",
                        ),
                      ],
                    ),
                  ),
                ],
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
      bottomNavigationBar: isWeb
          ? null // Tidak gunakan BottomBar pada Web
          : BottomBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
    );
  }
}

// Widget untuk Card pada bagian fitur
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FeatureCard({required this.icon, required this.title, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2C7566), // Warna hijau
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget untuk Statistik
class _StatisticCard extends StatelessWidget {
  final String title;
  final int count;

  const _StatisticCard({required this.title, required this.count, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "$count",
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}