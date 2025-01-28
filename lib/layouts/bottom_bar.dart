import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap; // Callback untuk perubahan indeks

  const BottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> routes = [
      '/', // Route untuk Home
      '/event', // Route untuk Event
      '/alumni', // Route untuk Alumni
      '/informasi', // Route untuk Informasi
      '/profil', // Route untuk Profile
    ];

    return Stack(
      clipBehavior: Clip.none, // Nonaktifkan clipping
      alignment: Alignment.bottomCenter,
      children: [
        BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Hilangkan animasi bergeser
          currentIndex: currentIndex,
          onTap: (index) {
            onTap(index);
            context.go(routes[index]); // Navigasi ke rute yang sesuai
          },
          selectedItemColor: const Color.fromARGB(255, 23, 114, 110),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Kegiatan',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(), // Kosongkan slot untuk alumni
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: 'Informasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
        Positioned(
          bottom: 20, // Posisi ikon Alumni
          child: GestureDetector(
            onTap: () {
              onTap(2); // Callback ke indeks Alumni
              context.go('/alumni'); // Navigasi langsung ke Alumni
            },
            child: Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 23, 114, 110),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.people,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}