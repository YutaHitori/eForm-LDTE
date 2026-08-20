import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
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
