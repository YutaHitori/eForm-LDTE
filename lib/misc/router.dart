import 'package:eform_ldte/admin/fakultas.dart';
import 'package:eform_ldte/admin/mata_kuliah.dart';
import 'package:eform_ldte/admin/program_studi.dart';
import 'package:eform_ldte/form/peminjaman_peralatan/detail.dart';
import 'package:eform_ldte/form/surat_keterangan_praktikum/detail.dart';
import 'package:eform_ldte/admin/config.dart';
import 'package:eform_ldte/misc/widget.dart';
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

String prev = '';

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
            return GetXRouteBinding(
              controllerBuilder: () => Get.put(PeminjamanPeralatanController()),
              child: Pinjam(),
            );
          },
        ),
        GoRoute(
          path: 'surat-keterangan',
          builder: (context, state) {
            return GetXRouteBinding(
              controllerBuilder: () => Get.put(SuratKeteranganPraktikumController()),
              child: SuratKeteranganPraktikum(),
            );
          },
        ),
        GoRoute(
          path: 'pertukaran-jadwal',
          builder: (context, state) {
            return GetXRouteBinding(
              controllerBuilder: () => Get.put(PertukaranJadwalPraktikumController()),
              child: PertukaranJadwalPraktikum(),
            );
          },
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
        final temp = redirect(reqLogin: false);
        if (temp == null) {
          NC.currentPage.value = NamedRoute.login;
        } 
        return temp;
      },
      pageBuilder: (context, state) {
        return NoTransitionPage(child: AppLayout());
      } ,
    ),
    GoRoute(
      path: '/admin',
      redirect: (context, state) {
        final temp = redirect();
        if (temp == null) {
          NC.currentPage.value = NamedRoute.admin;
        }
        return temp;
      },
      pageBuilder: (context, state) {
        return NoTransitionPage(child: AppLayout());
      },
      routes: [
        GoRoute(
          path: 'peminjaman-peralatan',
          redirect: (context, state) {
            return redirect();
          },
          builder: (context, state) {
            return GetXRouteBinding(
              controllerBuilder: () => Get.put(AdminPeminjamanPeralatanController()),
              child: AdminPeminjamanPeralatan(),
            );
          },
          routes: [
            GoRoute(
              path: ':id',
              redirect: (context, state) {
                return redirect();
              },
              builder: (context, state) {
                return GetXRouteBinding(
                  controllerBuilder: () => Get.put(DetailPeminjamanPeralatanController()),
                  child: DetailPeminjamanPeralatan(),
                );
              },
              onExit: (context, state) {
                getFindCall<AdminPeminjamanPeralatanController>()?.qfsp.onChanged();
                return true;
              },
            ),
          ]
        ),
        GoRoute(
          path: 'surat-keterangan',
          redirect: (context, state) {
            return redirect();
          },
          builder: (context, state) {
            return GetXRouteBinding(
              controllerBuilder: () => Get.put(AdminSuratKeteranganPraktikumController()),
              child: AdminSuratKeteranganPraktikum(),
            );
          },
          routes: [
            GoRoute(
              path: ':id',
              redirect: (context, state) {
                return redirect();
              },
              builder: (context, state) {
                return GetXRouteBinding(
                  controllerBuilder: () => Get.put(DetailSuratKeteranganPraktikumController()),
                  child: DetailSuratKeteranganPraktikum(),
                );
              },
              onExit: (context, state) {
                getFindCall<AdminSuratKeteranganPraktikumController>()?.qfsp.onChanged();
                return true;
              },
            ),
          ]
        ),
        GoRoute(
          path: 'config',
          redirect: (context, state) {
            return redirect();
          },
          builder: (context, state) {
            return GetXRouteBinding(
              controllerBuilder: () => Get.put(GlobalConfigController()),
              child: GlobalConfig(),
            );
          },
          onExit: (context, state) => Get.find<GlobalConfigController>().saveAllDialog(),
          routes: [
            GoRoute(
              path: 'list',
              redirect: (context, state) {
                return redirect();
              },
              builder: (context, state) {
                return GetXRouteBinding(
                  controllerBuilder: () => Get.put(FakultasController()),
                  child: Fakultas(),
                );
              },
              routes: [
                GoRoute(
                  path: ':fakultas',
                  redirect: (context, state) {
                    return redirect();
                  },
                  builder: (context, state) => GetXRouteBinding(
                    controllerBuilder: () => Get.put(ProgramStudiController()),
                    child: ProgramStudi(),
                  ),
                  onExit: (context, state) {
                    getFindCall<FakultasController>()?.qfsped.refresh();
                    return true;
                  },
                  routes: [
                    GoRoute(
                      path: ':program_studi',
                      redirect: (context, state) {
                        return redirect();
                      },
                      builder: (context, state) => GetXRouteBinding(
                        controllerBuilder: () => Get.put(MatprakController()),
                        child: Matprak(),
                      ),
                      onExit: (context, state) {
                        getFindCall<ProgramStudiController>()?.qfsped.refresh();
                        return true;
                      },
                    ),
                  ]
                ),
              ]
            ),
          ]
        ),
      ]
    ),
  ],
);

bool onExit<T>(String route, [bool Function()? condition]) {
  if (route.contains(router.state.fullPath!) && prev.length < route.length) {
    if (condition != null && !condition()) return false;
    Future.microtask(() {
      if (null is! T) Get.delete<T>(force: true);
    });
  }
  return true;
}

String? redirect({bool reqLogin = true}) {
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