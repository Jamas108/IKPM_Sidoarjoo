import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/kritik_controller.dart';
import '../auth/auth_provider.dart';
import '../layouts/navbar_layout.dart';

class KritikPage extends StatelessWidget {
  const KritikPage({super.key});

  @override
  Widget build(BuildContext context) {
    final kritikController = Provider.of<KritikController>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final TextEditingController kritikControllerInput = TextEditingController();

    void submitKritik() async {
      try {
        final stambuk = authProvider.isLoggedIn
            ? authProvider.userStambuk ?? 'guest'
            : 'guest';
        final nama = authProvider.isLoggedIn
            ? authProvider.userNama ?? 'Guest'
            : 'Guest';

        final kritik = kritikControllerInput.text;

        if (kritik.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kritik tidak boleh kosong')),
          );
          return;
        }

        await kritikController.submitKritik(
          stambuk: stambuk,
          nama: nama,
          kritik: kritik,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kritik berhasil dikirim')),
        );

        kritikControllerInput.clear();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim kritik')),
        );
      }
    }

    return Scaffold(
      appBar: const Navbar(), // Navbar di atas halaman
      body: Column(
        children: [
          // Konten utama halaman menggunakan Expanded agar mengisi ruang yang tersedia
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Banner di atas halaman
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 2,
                    child: Image.asset(
                      'assets/bannerkritik.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Padding lebih besar di sekitar konten utama
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0), // Jarak horizontal lebih besar
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Masukkan Kritik dan Saran:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: kritikControllerInput,
                          maxLines: 5,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            hintText:
                                'Tuliskan kritik dan saran Anda di sini...',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: kritikController.isSubmitting
                              ? null
                              : submitKritik,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C7566),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: kritikController.isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Kirim',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Footer menempel di bawah halaman
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
    );
  }
}
