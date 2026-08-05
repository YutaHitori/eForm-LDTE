import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/form/peminjaman_peralatan/admin.dart';
import 'package:eform_ldte/form/peminjaman_peralatan/form.dart';
import 'package:eform_ldte/form/surat_keterangan_praktikum/admin.dart';
import 'package:eform_ldte/form/surat_keterangan_praktikum/form.dart';
import 'package:eform_ldte/homepage/layout.dart';
import 'package:eform_ldte/misc/function.dart';
import 'package:eform_ldte/misc/global.dart';
import 'package:eform_ldte/pertukaran_jadwal_praktikum/form.dart';

final GoRouter router = GoRouter(
  navigatorKey: Get.key,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) {
          NC.currentPage.value = NamedRoute.homepage;
          return null;
        },
        pageBuilder: (context, state) => NoTransitionPage(child: AppLayout()),
        routes: [
          GoRoute(
            path: 'peminjaman-peralatan',
            builder: (context, state) => Pinjam(),
            onExit: (context, state) => onExit<PeminjamanPeralatanController>(),
          ),
          GoRoute(
            path: 'surat-keterangan',
            builder: (context, state) => const SuratKeteranganPraktikum(),
            onExit: (context, state) => onExit<SuratKeteranganPraktikumController>()
          ),
          GoRoute(
            path: 'pertukaran-jadwal',
            builder: (context, state) => const PertukaranJadwalPraktikum(),
            onExit: (context, state) => onExit<PertukaranJadwalPraktikumController>()
          ),
          // GoRoute(
          //   path: 'settings',
          //   builder: (context, state) => const Settings(),
          //   onExit: (context, state) => onExit<SettingsController>(),
          // ),
        ]
      ),
      GoRoute(
        path: '/login',
        redirect: (context, state) {
          final temp = redirect(state.matchedLocation, reqLogin: false);
          if (temp == null) {
            NC.currentPage.value = NamedRoute.login;
          } 
          return temp;
        },
        pageBuilder: (context, state) => NoTransitionPage(child: const AppLayout()),
        onExit: (context, state) => onExit<LoginController>(),
      ),
      GoRoute(
        path: '/admin',
        redirect: (context, state) {
          final temp = redirect(state.matchedLocation);
          if (temp == null) {
            NC.currentPage.value = NamedRoute.admin;
          }
          return temp;
        },
        pageBuilder: (context, state) => NoTransitionPage(child: const AppLayout()),
        onExit: (context, state) => onExit<AdminController>(),
        routes: [
          GoRoute(
            path: 'peminjaman-peralatan',
            redirect: (context, state) {
              return redirect(state.matchedLocation);
            },
            builder: (context, state) => const AdminPeminjamanPeralatan(),
            onExit: (context, state) => onExit<AdminPeminjamanPeralatanController>(),
          ),
          GoRoute(
            path: 'surat-keterangan',
            redirect: (context, state) {
              return redirect(state.matchedLocation);
            },
            builder: (context, state) => const AdminSuratKeteranganPraktikum(),
            onExit: (context, state) => onExit<AdminSuratKeteranganPraktikumController>(),
          ),
        ]
      ),
    ]
);

bool onExit<T>() {
    if (null is! T) Get.delete<T>(force: true);
    return true;
  }

  String? redirect(String? nroute, {bool reqLogin = true}) {

    if (!reqLogin) {
      if (auth.isLoggedIn) {
        Get.closeAllSnackbars();
        snackbar('Warning!', 'User already logged in');
        return NamedRoute.homepage;
      }
      return null;
    }
    
    if (!auth.isLoggedIn) { 
      Get.closeAllSnackbars();
      snackbar('Warning!', 'User not logged in');
      return NamedRoute.login;
    }

    return null;
  }