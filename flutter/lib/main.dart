import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:ldte_stei_itb/hive/hive_registrar.g.dart';
import 'package:ldte_stei_itb/misc/widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ldte_stei_itb/misc/global.dart';
import 'package:ldte_stei_itb/misc/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  if (kIsWeb) usePathUrlStrategy();

  GoRouter.optionURLReflectsImperativeAPIs = true;

  WidgetsFlutterBinding.ensureInitialized();

  initializeDateFormatting('id_ID');

  await Hive.initFlutter();
  Hive.registerAdapters(); 

  await Supabase.initialize(
    url: "https://xulfjcgekimkkijjswqm.supabase.co",
    publishableKey: "sb_publishable_2FRbSQMkCHktF4c8jKqEuA_eDMrZZkp",
  );
  auth.listenAuthChange();

  await storage.initialize();

  runApp(
    MaterialApp.router(
      routerConfig: router,
      // builder: (context, child) => LayoutBuilder(
      //   builder:(context, constraints) {
      //     debounceCallback(() {
      //       Future(() { 
      //         final double uiScale = Get.isRegistered<SettingsController>() ? Get.find<SettingsController>().uiScale.value : preference.uiScale;
      //         ScaledWidgetsFlutterBinding.instance.scaleFactor = 
      //           (size) => (size.width /  (Get.width > (432) ? Get.width : 432)) * uiScale;
      //       });
      //     });
      //     return child!;
      //   }
      // ), 
      title: 'LDTE STEI ITB',
      theme: appTheme,
    ),
  );
}
