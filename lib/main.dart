import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:eform_ldte/hive/hive_registrar.g.dart';
import 'package:eform_ldte/misc/widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:eform_ldte/misc/global.dart';
import 'package:eform_ldte/misc/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  usePathUrlStrategy();
  
  GoRouter.optionURLReflectsImperativeAPIs = true;

  WidgetsFlutterBinding.ensureInitialized();

  initializeDateFormatting('id_ID');

  await Supabase.initialize(
    url: "https://xulfjcgekimkkijjswqm.supabase.co",
    publishableKey: "sb_publishable_2FRbSQMkCHktF4c8jKqEuA_eDMrZZkp",
  );
  auth.listenAuthChange();

  await storage.initialize();

  runApp(
    MaterialApp.router(
      routerConfig: router,
      title: 'eForm LDTE',
      theme: appTheme,
    ),
  );
}
