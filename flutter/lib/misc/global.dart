import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ldte_stei_itb/core/controller.dart';
import 'package:ldte_stei_itb/core/service.dart';
import 'package:pdf/widgets.dart' as pw;

final auth = AuthService();
final storage = StorageService();

final NC = Get.put(NavigationController());

final fakultas = [
  "Fakultas Ilmu dan Teknologi Kebumian (FITB)", 
  "Fakultas Matematika dan Ilmu Pengetahuan Alam (FMIPA)", 
  "Fakultas Seni Rupa dan Desain (FSRD)", 
  "Fakultas Teknik Mesin dan Dirgantara (FTMD)", 
  "Fakultas Teknik Pertambangan dan Perminyakan (FTTM)", 
  "Fakultas Teknik Sipil dan Lingkungan (FTSL)", 
  "Fakultas Teknologi Industri (FTI)", 
  "Sekolah Arsitektur, Perencanaan dan Pengembangan Kebijakan (SAPPK)", 
  "Sekolah Bisnis dan Manajemen (SBM)", 
  "Sekolah Farmasi (SF)", 
  "Sekolah Ilmu dan Teknologi Hayati (SITH)", 
  "Sekolah Teknik Elektro dan Informatika (STEI)"
];

final items = ['custom', 'Oscilloscope', 'Multimeter', 'Signal Generator'];

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
  static const login = '/login';

  static const admin = '/admin';
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