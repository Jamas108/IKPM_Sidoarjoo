import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return AppBar(
      automaticallyImplyLeading: false,
      title: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 850) {
            // Untuk layar kecil (misal: ponsel), tampilkan logo dan dropdown
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/ikpmlogoonly.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                const Text(
                  'IKPM SIDOARJO',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                // Tombol hamburger untuk membuka dropdown
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _showDropdownMenu(context, authProvider),
                ),
              ],
            );
          } else {
            // Untuk layar lebar, tampilkan logo dan menu navbar biasa
            return Row(
              children: [
                Image.asset(
                  'assets/ikpmlogoonly.png',
                  width: 40,
                  height: 40,
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
                const Spacer(),
                _navbarItem(context, 'Beranda', '/'),
                _navbarItem(context, 'Alumni', '/alumni'),
                _navbarItem(context, 'Kegiatan', '/kegiatan'),
                _navbarItem(context, 'Informasi', '/informasi'),
                _navbarItem(context, 'Kritik & Saran', '/kritik'),
                _navbarItem(context, 'Profil', '/profil'),
                authProvider.isLoggedIn
                    ? _logoutButton(context, authProvider)
                    : _loginButton(context),
              ],
            );
          }
        },
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
    );
  }

  // Menampilkan menu dropdown untuk layar kecil
  void _showDropdownMenu(BuildContext context, AuthProvider authProvider) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100.0, 60.0, 0.0, 0.0),
      items: [
        PopupMenuItem<String>(
          value: '/beranda',
          child: TextButton(
            onPressed: () {
              context.go('/');
              Navigator.pop(context);
            },
            child: const Text('Beranda'),
          ),
        ),
        PopupMenuItem<String>(
          value: '/alumni',
          child: TextButton(
            onPressed: () {
              context.go('/alumni');
              Navigator.pop(context);
            },
            child: const Text('Alumni'),
          ),
        ),
        PopupMenuItem<String>(
          value: '/kegiatan',
          child: TextButton(
            onPressed: () {
              context.go('/kegiatan');
              Navigator.pop(context);
            },
            child: const Text('Kegiatan'),
          ),
        ),
        PopupMenuItem<String>(
          value: '/informasi',
          child: TextButton(
            onPressed: () {
              context.go('/informasi');
              Navigator.pop(context);
            },
            child: const Text('Informasi'),
          ),
        ),
        PopupMenuItem<String>(
          value: '/kritik',
          child: TextButton(
            onPressed: () {
              context.go('/kritik');
              Navigator.pop(context);
            },
            child: const Text('Kritik & Saran'),
          ),
        ),
        PopupMenuItem<String>(
          value: '/profil',
          child: TextButton(
            onPressed: () {
              context.go('/profil');
              Navigator.pop(context);
            },
            child: const Text('Profil'),
          ),
        ),
        if (authProvider.isLoggedIn)
          PopupMenuItem<String>(
            value: 'logout',
            child: TextButton(
              onPressed: () async {
                final confirmed = await _showLogoutConfirmation(context);
                if (confirmed) {
                  authProvider.logout();
                  context.go('/'); // Redirect ke HomePage
                  Navigator.pop(context);
                }
              },
              child: const Text('Logout'),
            ),
          )
        else
          PopupMenuItem<String>(
            value: 'login',
            child: TextButton(
              onPressed: () {
                context.go('/login');
                Navigator.pop(context);
              },
              child: const Text('Login'),
            ),
          ),
      ],
    );
  }

  Widget _navbarItem(BuildContext context, String title, String route) {
    // Mendapatkan lokasi aktif dari GoRouter
    final String currentRoute = GoRouter.of(context)
            .routerDelegate
            .currentConfiguration
            ?.uri
            .toString() ??
        '/';

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
                  ? const Color(0xFF2C7566) // Warna untuk item aktif
                  : Colors.black.withOpacity(0.7), // Warna default
              fontWeight:
                  currentRoute == route ? FontWeight.bold : FontWeight.w500,
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
          backgroundColor:
              const Color.fromARGB(255, 23, 114, 110), // Warna hijau
          foregroundColor: Colors.white, // Warna teks dan ikon
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Sudut melengkung
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          elevation: 3, // Elevasi tombol
        ),
        icon: const Icon(Icons.login,
            size: 20, color: Colors.white), // Ikon putih
        label: const Text(
          'Login',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: Colors.white, // Teks putih
          ),
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
