import 'package:eform_ldte/admin/fakultas.dart';
import 'package:eform_ldte/admin/mata_kuliah.dart';
import 'package:eform_ldte/admin/program_studi.dart';
import 'package:eform_ldte/form/peminjaman_peralatan/detail.dart';
import 'package:eform_ldte/form/surat_keterangan_praktikum/detail.dart';
import 'package:eform_ldte/admin/config.dart';
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
            builder: (context, state) {
              Get.put(PeminjamanPeralatanController());
              return const Pinjam();
            },
            onExit: (context, state) => onExit<PeminjamanPeralatanController>(),
          ),
          GoRoute(
            path: 'surat-keterangan',
            builder: (context, state) {
              Get.put(SuratKeteranganPraktikumController());
              return const SuratKeteranganPraktikum();
            },
            onExit: (context, state) => onExit<SuratKeteranganPraktikumController>()
          ),
          GoRoute(
            path: 'pertukaran-jadwal',
            builder: (context, state) {
              Get.put(PertukaranJadwalPraktikumController());
              return  const PertukaranJadwalPraktikum();
            },
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
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: AppLayout());
        } ,
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
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: AppLayout());
        },
        onExit: (context, state) => onExit<AdminController>(),
        routes: [
          GoRoute(
            path: 'peminjaman-peralatan',
            redirect: (context, state) {
              return redirect(state.matchedLocation);
            },
            builder: (context, state) {
              Get.put(AdminPeminjamanPeralatanController());
              return const AdminPeminjamanPeralatan();
            },
            onExit: (context, state) => onExit<AdminPeminjamanPeralatanController>(),
            routes: [
              GoRoute(
                path: ':id',
                redirect: (context, state) {
                  return redirect(state.matchedLocation);
                },
                builder: (context, state) {
                  Get.put(DetailPeminjamanPeralatanController(int.tryParse(state.pathParameters['id'] ?? '') ?? -1));
                  return DetailPeminjamanPeralatan();
                },
                onExit: (context, state) => onExit<DetailPeminjamanPeralatanController>(),
              ),
            ]
          ),
          GoRoute(
            path: 'surat-keterangan',
            redirect: (context, state) {
              return redirect(state.matchedLocation);
            },
            builder: (context, state) {
              Get.put(AdminSuratKeteranganPraktikumController());
              return const AdminSuratKeteranganPraktikum();
            },
            onExit: (context, state) => onExit<AdminSuratKeteranganPraktikumController>(),
            routes: [
              GoRoute(
                path: ':id',
                redirect: (context, state) {
                  return redirect(state.matchedLocation);
                },
                builder: (context, state) {
                  Get.put(DetailSuratKeteranganPraktikumController(int.tryParse(state.pathParameters['id'] ?? '') ?? -1));
                  return DetailSuratKeteranganPraktikum();
                },
                onExit: (context, state) => onExit<DetailSuratKeteranganPraktikumController>(),
              ),
            ]
          ),
          GoRoute(
            path: 'config',
            redirect: (context, state) {
              return redirect(state.matchedLocation);
            },
            builder: (context, state) {
              Get.put(GlobalConfigController());
              return const GlobalConfig();
            },
            onExit: (context, state) =>  Get.find<GlobalConfigController>().saveAllDialog() ? onExit<GlobalConfigController>() : false,
            routes: [
              GoRoute(
                path: 'list',
                redirect: (context, state) {
                  return redirect(state.matchedLocation);
                },
                builder: (context, state) {
                  Get.put(FakultasController());
                  return const Fakultas();
                },
                onExit: (context, state) => onExit<FakultasController>(),
                routes: [
                  GoRoute(
                    path: ':fakultas',
                    redirect: (context, state) {
                      return redirect(state.matchedLocation);
                    },
                    builder: (context, state) {
                      Get.put(ProgramStudiController(state.pathParameters['fakultas']!));
                      return ProgramStudi();
                    },
                    onExit: (context, state) => onExit<ProgramStudiController>(),
                    routes: [
                      GoRoute(
                        path: ':program_studi',
                        redirect: (context, state) {
                          return redirect(state.matchedLocation);
                        },
                        builder: (context, state) {
                          Get.put(MatprakController(state.pathParameters['program_studi']!));
                          return Matprak();
                        },
                        onExit: (context, state) => onExit<MatprakController>(),
                        routes: []
                      ),
                    ]
                  ),
                ]
              ),
            ]
          ),
        ]
      ),
    ]
);

bool onExit<T>() {
    Future.microtask(() {
      if (null is! T) Get.delete<T>(force: true);
    });
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