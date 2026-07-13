import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:ldte_stei_itb/hive/hive_registrar.g.dart';
import 'package:ldte_stei_itb/homepage/admin.dart';
import 'package:ldte_stei_itb/core/custom-widget.dart';
import 'package:ldte_stei_itb/core/middleware.dart';
import 'package:ldte_stei_itb/form/surat_keterangan_praktikum/admin.dart';
import 'package:ldte_stei_itb/form/surat_keterangan_praktikum/form.dart';
import 'package:ldte_stei_itb/form/peminjaman_peralatan/form.dart';
import 'package:ldte_stei_itb/homepage/homepage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ldte_stei_itb/homepage/login.dart';
import 'package:ldte_stei_itb/misc/global.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  if (kIsWeb) setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  initializeDateFormatting('id_ID');

  await Hive.initFlutter();
  Hive.registerAdapters(); 

  await Supabase.initialize(
    url: "https://xulfjcgekimkkijjswqm.supabase.co",
    publishableKey: "sb_publishable_2FRbSQMkCHktF4c8jKqEuA_eDMrZZkp",
  );
  auth.listenAuthChange();

  storage.initialize();

  runApp(
    GetMaterialApp(
      theme: appTheme,
      title: 'LDTE STEI ITB',
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => Homepage()),
        GetPage(name: '/form/pinjam', page: () => Pinjam()),
        GetPage(name: '/form/keterangan', page: () => SuratKeteranganPraktikum()),
        GetPage(name: '/login', page: () => Login(), middlewares: [ AuthMiddleware(reqLogin: false) ]),
        GetPage(name: '/admin', page: () => Admin(), middlewares: [ AuthMiddleware() ]),
        GetPage(name: '/admin/keterangan', page: () => AdminSuratKeteranganPraktikum(), middlewares: [ AuthMiddleware() ]),
      ],
    ),
  );
}
