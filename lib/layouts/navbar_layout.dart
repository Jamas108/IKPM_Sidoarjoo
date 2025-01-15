import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final authProvider = Provider.of<AuthProvider>(context);

        return AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Image.asset(
                'assets/ikpmlogoonly.png', // Gambar logo dari assets
                width: 40, // Lebar gambar
                height: 40, // Tinggi gambar
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              const Text(
                'IKPM SIDOARJO',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          centerTitle: false,
          elevation: 4.0,
          shadowColor: Colors.grey.shade300,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          titleTextStyle: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            _navbarItem(context, 'Beranda', '/'),
            _navbarItem(context, 'Alumni', '/alumni'),
            _navbarItem(context, 'Kegiatan', '/event'),
            _navbarItem(context, 'Informasi', '/informasi'),
            _navbarItem(context, 'Kritik & Saran', '/kritik'),
            _navbarItem(context, 'Profil', '/profil'),
            authProvider.isLoggedIn
                ? _logoutButton(context, authProvider)
                : _loginButton(context),
          ],
        );
      },
    );
  }

Widget _navbarItem(BuildContext context, String title, String route) {
  // Mendapatkan lokasi aktif dari GoRouter
  final String currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration?.uri.toString() ?? '/';

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () {
          context.go(route); // Navigasi ke route
        },
        child: Text(
          title,
          style: TextStyle(
            color: currentRoute == route
                ?const Color(0xFF2C7566) // Warna untuk item aktif
                : Colors.black.withOpacity(0.7), // Warna default
            fontWeight: currentRoute == route ? FontWeight.bold : FontWeight.w500,
            fontSize: 16.0,
          ),
        ),
      ),
    ),
  );
}

  Widget _loginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton.icon(
        onPressed: () {
          context.go('/login'); // Navigasi ke halaman login
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          elevation: 3,
        ),
        icon: const Icon(Icons.login, size: 20),
        label: const Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirmed = await _showLogoutConfirmation(context);
          if (confirmed) {
            authProvider.logout();
            context.go('/'); // Redirect ke HomePage
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          elevation: 3,
        ),
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
      ),
    );
  }

  Future<bool> _showLogoutConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah Anda yakin ingin logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}
