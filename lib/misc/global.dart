import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/core/service.dart';
import 'package:pdf/widgets.dart' as pw;

final auth = AuthService();
final storage = StorageService();

final NC = Get.put(NavigationController());

pw.TextStyle textStyle({double? fontSize, double? lineSpacing}) {
  return pw.TextStyle(
    fontWeight: pw.FontWeight.normal,
    fontSize: fontSize ?? 12,
    lineSpacing: lineSpacing ?? 5
  );
}

final regexp = RegExp(r'\((.*?)\)');

DateTime get now => DateTime.now();
DateTime get today => DateTime.parse(now.toString().substring(0, 10));
DateTime get todayEnd => today.add(Duration(days: 1)).subtract(Duration(seconds: 1));

class NamedRoute {
  static const homepage = '/';
  static const settings = '/settings';
  static const pinjam = '/peminjaman-peralatan';
  static const keterangan = '/surat-keterangan';
  static const pertukaran = '/pertukaran-jadwal';
  static const izin = '/surat-izin';
  static const login = '/login';

  static const admin = '/admin';
  static const config = '/admin/config';
  static const list = '/admin/config/list';
  static const barang = '/admin/config/barang';
  static const pinjamAdmin = '/admin/peminjaman-peralatan';
  static const keteranganAdmin = '/admin/surat-keterangan';
}

final webAlwaysScrollable = kIsWeb ? AlwaysScrollableScrollPhysics() : null;

final connection = InternetConnection.createInstance(
  useDefaultOptions: kIsWeb, 
  customCheckOptions: [
    InternetCheckOption(uri: Uri.parse('http://connectivitycheck.gstatic.com/generate_204')),
    InternetCheckOption(uri: Uri.parse('http://www.apple.com/library/test/success.html')),
    InternetCheckOption(uri: Uri.parse('http://www.msftconnecttest.com/connecttest.txt')),
    InternetCheckOption(uri: Uri.parse('http://fedoraproject.org/static/hotspot.txt')),
  ]
);