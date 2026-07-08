import 'dart:typed_data';

import 'package:get/instance_manager.dart';
import 'package:ldte_stei_itb/core/controller.dart';
import 'package:ldte_stei_itb/core/service.dart';
import 'package:pdf/widgets.dart' as pw;

final auth = AuthService();

final NC = Get.put(HomePageController());

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