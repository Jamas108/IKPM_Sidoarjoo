import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikpm_sidoarjo/admin/alumni/create_page.dart';
import 'package:ikpm_sidoarjo/admin/alumni/detail_page.dart';
import 'package:ikpm_sidoarjo/admin/alumni/edit_page.dart';
import 'package:ikpm_sidoarjo/admin/alumni/edit_password_page.dart';
import 'package:ikpm_sidoarjo/admin/alumni/index_page.dart';
import 'package:ikpm_sidoarjo/admin/kritik/index_page.dart';
import 'package:ikpm_sidoarjo/admin/profil/edit_page.dart';
import 'package:ikpm_sidoarjo/admin/profil/edit_password_page.dart';
import 'package:ikpm_sidoarjo/admin/profil/index_page.dart';
import 'package:ikpm_sidoarjo/alumni/detail_alumni_page.dart';
import 'package:ikpm_sidoarjo/controllers/kritik_controller.dart';
import 'package:ikpm_sidoarjo/controllers/login_controller.dart';
import 'package:ikpm_sidoarjo/kritik/riwayat_kritik_page.dart';
import 'package:ikpm_sidoarjo/profil/edit_password_page.dart';
import 'package:ikpm_sidoarjo/profil/edit_profil_page.dart';
import 'package:provider/provider.dart';
import 'auth/auth_provider.dart';
import 'home_page.dart';
import 'auth/login_page.dart';
import 'informasi/informasi_page.dart';
import 'event/kegiatan_page.dart';
import 'kritik/kritik_page.dart';
import 'profil/profil_page.dart';
import 'alumni/alumni_page.dart';
import 'event/kegiatan_detail_page.dart';
import 'models/event_model.dart';
import 'controllers/kegiatan_controller.dart';
import 'models/informasi_model.dart';
import 'informasi/detail_informasi.page.dart';
import 'admin/home_page.dart';
import 'admin/event/index_page.dart';
import 'admin/informasi/index_page.dart';
import 'admin/event/create_page.dart';
import 'admin/event/participant_page.dart';
import 'admin/event/edit_page.dart';
import 'admin/informasi/show_page.dart';
import 'admin/informasi/edit_page.dart';
import 'admin/informasi/create_page.dart';
// import 'admin/event/edit_page.dart';
import 'admin/event/show_page.dart';
import 'package:flutter/foundation.dart';
import 'event/riwayat_event_page.dart';
import 'controllers/alumni_controller.dart';
import 'profil/settings_page.dart';
// import 'package:ikpm_sidoarjo/profil/edit_password_page.dart' as password;
// Tambahkan import EventController

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadSession()),
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => KritikController()),
        ChangeNotifierProvider(create: (_) => AlumniController()),
        Provider(
            create: (_) =>
                EventController()), // Tambahkan EventController sebagai provider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router, // Konfigurasi GoRouter
    );
  }
}

// Konfigurasi GoRouter
final GoRouter _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Jika pengguna belum login dan platform mobile, arahkan ke halaman login
    if (!authProvider.isLoggedIn && !kIsWeb && state.location != '/login') {
      return '/login';
    }

    // Tetap di lokasi saat ini jika syarat login terpenuhi atau di web
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    //ADMIN ROUTE
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const HomePageAdmin(), // Halaman admin
    ),

    GoRoute(
      path: '/admin/events',
      builder: (context, state) => const EventPageAdmin(),
      routes: [
        GoRoute(
          path: 'create',
          builder: (context, state) =>
              const AddEventPage(), // Halaman tambah event
        ),
        GoRoute(
          path: 'detail/:id',
          builder: (context, state) {
            final event =
                state.extra as EventModel; // Mengambil data event dari extra
            return ShowEventPage(
                event: event); // Pastikan event dikirim ke halaman edit
          },
        ),
        GoRoute(
          path: 'edit/:id',
          builder: (context, state) {
            final event =
                state.extra as EventModel; // Mengambil data event dari extra
            return EditEventPage(
                event: event); // Pastikan event dikirim ke halaman edit
          },
        ),
        GoRoute(
          path: ':id/participants',
          builder: (context, state) {
            final kegiatanId = state.pathParameters['id']!;
            final eventName = state.extra != null
                ? (state.extra as Map<String, dynamic>)['eventName'] as String
                : 'Unknown Event'; // Default jika extra tidak ada

            return EventParticipantsPage(
              kegiatanId: kegiatanId,
              eventName: eventName, // Teruskan eventName ke halaman
            );
          },
        ),
      ],
    ),

    GoRoute(
      path: '/admin/alumni',
      builder: (context, state) => const AlumniPageAdmin(),
      routes: [
        GoRoute(
          path: 'create',
          builder: (context, state) => const AddAlumniPage(),
        ),
        GoRoute(
          path: 'edit/:stambuk', // Menggunakan parameter `stambuk`
          builder: (context, state) {
            final stambuk = state.pathParameters['stambuk']!;
            return EditAlumniPage(stambuk: stambuk);
          },
        ),
        GoRoute(
          path: 'details/:stambuk',
          builder: (context, state) {
            final stambuk = state.pathParameters['stambuk']!;
            return AlumniDetailPage(stambuk: stambuk);
          },
        ),
        GoRoute(
          path: 'edit-password/:stambuk',
          builder: (context, state) {
            final stambuk = state.pathParameters['stambuk']!;
            return EditPasswordAlumniPage(stambuk: stambuk);
          },
        ),
      ],
    ),

    GoRoute(
      path: '/admin/informasi',
      builder: (context, state) => const InformasiPageAdmin(),
      routes: [
        GoRoute(
          path: 'detail/:id',
          builder: (context, state) {
            final informasiId = state.pathParameters['id']!;
            return ShowInformasiPage(
              informasiId: informasiId, // Gunakan parameter ini
            );
          },
        ),
        GoRoute(
          path: 'edit/:id',
          builder: (context, state) {
            final informasiId = state.pathParameters['id']!;
            return EditInformasiPage(
              informasiId: informasiId, // Gunakan parameter ini
            );
          },
        ),
        GoRoute(
          path: 'create',
          builder: (context, state) => const AddInformasiPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/admin/profil',
      builder: (context, state) => const AdminProfilPage(),
    ),
    GoRoute(
      path: '/admin/edit-profile',
      builder: (context, state) => const EditProfileAdminPage(),
    ),
    GoRoute(
      path: '/admin/edit-password',
      builder: (context, state) => const EditPasswordAdminPage(),
    ),

    //PUBLIC ROUTE
    GoRoute(
      path: '/informasi',
      builder: (context, state) => const InformasiPage(),
      routes: [
        GoRoute(
          path: 'detail/:id',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final InformasiModel informasi =
                extra['informasi'] as InformasiModel; // Ambil data dari extra
            return DetailInformasi(
              informasi: informasi, // Kirim data ke halaman detail
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/kegiatan',
      builder: (context, state) => const EventPage(),
      routes: [
        GoRoute(
          path: 'detail/:id', // Sub-rute untuk detail event
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final EventModel event = extra['event'] as EventModel;
            return DetailEvent(
                event: event); // Kirim data EventModel ke halaman detail
          },
        ),
      ],
    ),

    GoRoute(
      path: '/kritik',
      builder: (context, state) => const KritikPage(),
    ),
    GoRoute(
      path: '/profil',
      builder: (context, state) => const ProfilPage(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/edit-password',
      builder: (context, state) => const EditPasswordPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/riwayat-event',
      builder: (context, state) => const RiwayatEventPage(),
    ),
    GoRoute(
      path: '/riwayat-kritik',
      builder: (context, state) => const RiwayatKritikPage(),
    ),
    GoRoute(
      path: '/alumni',
      builder: (context, state) => const AlumniPage(),
    ),
    GoRoute(
      path: '/alumni/:stambuk',
      builder: (context, state) {
        // Menggunakan pathParameters untuk mengambil stambuk
        final stambuk = state.pathParameters['stambuk']!;
        return DetailAlumniPage(stambuk: stambuk);
      },
    ),
    GoRoute(
      path: '/admin/kritik',
      builder: (context, state) => const KritikPageAdmin(),
    ),
  ],
);
