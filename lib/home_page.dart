import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layouts/navbar_layout.dart';
import '../layouts/bottom_bar.dart';

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
    final bool isWeb = kIsWeb;

    return Scaffold(
      appBar: isWeb
          ? const Navbar()
          : AppBar(
              title: const Text(
                "Beranda",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20, // Ukuran font lebih besar
                  fontWeight:
                      FontWeight.w600, // Berat font medium untuk kesan elegan
                  fontFamily: 'Roboto', // Gunakan font elegan, contoh: Roboto
                  letterSpacing: 1.2, // Memberikan spasi antar huruf
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 23, 114, 110),
            ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/ikpmsidoarjobanner.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: const Text(
                        "SELAMAT DATANG DI IKPM SIDOARJO",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: MediaQuery.of(context).size.width < 600
                          ? const EdgeInsets.symmetric(
                              horizontal: 16.0) // Padding ketika layar kecil
                          : const EdgeInsets.symmetric(
                              horizontal:
                                  32.0), // Padding lebih besar untuk layar besar
                      child: const Text(
                        "Berisi tentang sekumpulan informasi tentang alumni, kegiatan serta berita tentang Keluarga IKPM Cabang Sidoarjo.\nSemoga bermanfaat dan menambah wawasan anda :)",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.go('/login'); // Arahkan ke halaman login
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFFFF),
                            foregroundColor: const Color(0xFF2C7566),
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
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _scrollPosition > 200 ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Menentukan jumlah kolom berdasarkan lebar layar
                    int crossAxisCount = constraints.maxWidth > 800
                        ? 4
                        : constraints.maxWidth > 600
                            ? 3
                            : 2;

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0), // Padding kiri dan kanan
                      children: [
                        _FeatureCard(
                          icon: Icons.desktop_mac,
                          title: "Data Alumni",
                          onTap: () {
                            context.go('/alumni');
                          },
                        ),
                        _FeatureCard(
                          icon: Icons.event,
                          title: "Agenda Kegiatan",
                          onTap: () {
                            context.go('/event');
                          },
                        ),
                        _FeatureCard(
                          icon: Icons.newspaper,
                          title: "Berita Terkini",
                          onTap: () {
                            context.go('/informasi');
                          },
                        ),
                        _FeatureCard(
                          icon: Icons.contact_page,
                          title: "Kritik dan Saran",
                          onTap: () {
                            context.go('/kritik');
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _scrollPosition > 400 ? 1 : 0,
              child: Column(
                children: [
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal:
                            32.0), // Padding kiri dan kanan seperti pada feature card
                    child: const Text(
                      "Website ini dibuat untuk memberikan informasi terkait data alumni, kegiatan, serta berita terkini yang berhubungan dengan IKPM Sidoarjo. Kami berharap website ini menjadi sarana yang bermanfaat untuk Anda.",
                      textAlign: TextAlign.justify, // Teks di-justify
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(3, (index) {
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: _ContactCard(
                                  icon: index == 0
                                      ? Icons.phone
                                      : index == 1
                                          ? Icons.email
                                          : Icons.location_on,
                                  title: index == 0
                                      ? "Telepon"
                                      : index == 1
                                          ? "Email"
                                          : "Lokasi",
                                  content: index == 0
                                      ? "+62 123 4567 890"
                                      : index == 1
                                          ? "info@ikpmsidoarjo.com"
                                          : "Sidoarjo, Jawa Timur",
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
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
          ? null
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

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovering = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: _isHovering
            ? Matrix4.identity()
                .scaled(1.02) // Gunakan scaled() alih-alih chaining
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 248, 255),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: const Color.fromARGB(255, 43, 117, 101),
            width: 2,
          ),
          boxShadow: _isHovering
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 48,
                  color: const Color.fromARGB(255, 43, 117, 101),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 43, 117, 101),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.content,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width *
            0.25, // Responsif: Lebar card disesuaikan dengan lebar layar
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: const Color.fromARGB(255, 43, 117, 101),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
