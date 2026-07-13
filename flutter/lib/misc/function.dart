
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ldte_stei_itb/misc/extension.dart';

void phoneValidateFormatFocus(TextEditingController phone, FocusNode phoneFN, Rxn<String> phoneE) {
  String result = phone.text.trim();
  if (phoneFN.hasFocus) {
    result = result.replaceAll(' - ', '');
  } else if (!phoneFN.hasFocus) {
    phoneE.value = null;
    if (!result.verifyPhone()) {
      phoneE.value = '*phone number invalid';
      return;
    }
    result = '${result.substring(0, 3)} - ${result.substring(3, 7)} - ${result.substring(7)}';
  }
  phone.text = result;
}

void alertDialog(String title, String? subtitle, {double? height, double? width, Color? backgroundColor, String? image, Widget? message, List<Widget>? actions,  VoidCallback? cancelAction, String cancelText = 'Close', VoidCallback? confirmAction, String confirmText = 'Confirm', bool dismissible = true}) {
  Future(() => Get.dialog(
    PopScope(
      canPop: dismissible,
      child: AlertDialog(
        title: Text(title),
        content: Container(
          height: height,
          width: width ?? 256 + 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (image != null) Image.asset(image, scale: 5, alignment: AlignmentGeometry.center,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: subtitle != null ? Text(subtitle) : message,
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 24),
        actions: [
          TextButton(onPressed: cancelAction ?? Get.back, child: Text(cancelText)),
          if (confirmAction != null) ElevatedButton(onPressed: confirmAction, child: Text(confirmText)),
          if (actions != null) for (var action in actions) action
        ],
        actionsPadding: EdgeInsets.only(bottom: 8, right: 16),
      ),
    ),
    barrierDismissible: dismissible,
  ));
}

void snackbar(String title, String message, [IconData ? icon]) {
  Future(() => Get.snackbar(
    title, message, 
    margin: EdgeInsets.all(12),
    titleText: icon == null ? null : Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: Text(title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
    ),
    messageText: icon == null ? null : Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: Text(message,
        style: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 14,
        ),
      ),
    ),
    icon: icon == null ? null : Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Icon(icon, size: 32),
    ),
    barBlur: 16
  ));
}

List<String> getAvailableProdi(String? fakultas) {
  switch (fakultas) {
    case 'Fakultas Ilmu dan Teknologi Kebumian (FITB)': 
      return [
        "Meteorologi (ME)",
        "Oseanografi (OS)",
        "Teknik Geodesi dan Geomatika (GD)",
        "Teknik Geologi (GL)",
      ];
    case 'Fakultas Matematika dan Ilmu Pengetahuan Alam (FMIPA)': 
      return [
        "Aktuaria (AK)",
        "Astronomi (AS)",
        "Fisika (FI)",
        "Kimia (KI)",
        "Matematika (MA)",
      ];
    case 'Fakultas Seni Rupa dan Desain (FSRD)': 
      return [
        "Desain Interior (DI)",
        "Desain Komunikasi Visual (DKV)",
        "Desain Produk (DP)",
        "Kriya (KR)",
        "Seni Rupa (SR)",
      ];
    case 'Fakultas Teknik Mesin dan Dirgantara (FTMD)': 
      return [
        "Teknik Dirgantara (AE)",
        "Teknik Material (MT)",
        "Teknik Mesin (MS)",
      ];
    case 'Fakultas Teknik Pertambangan dan Perminyakan (FTTM)': 
      return [
        "Teknik Geofisika (TG)",
        "Teknik Metalurgi (MG)",
        "Teknik Perminyakan (TM)",
        "Teknik Pertambangan (TA)",
      ];
    case 'Fakultas Teknik Sipil dan Lingkungan (FTSL)': 
      return [
        "Rekayasa Infrastruktur Lingkungan (IL)",
        "Teknik dan Pengelolaan Sumber Daya Air (SA)",
        "Teknik Kelautan (KL)",
        "Teknik Lingkungan (TL)",
        "Teknik Sipil (SI)",
      ];
    case 'Fakultas Teknologi Industri (FTI)': 
      return [
        "Manajemen Rekayasa Industri (MR)",
        "Teknik Bioenergi dan Kemurgi (TB)",
        "Teknik Fisika (TF)",
        "Teknik Industri (TI)",
        "Teknik Kimia (TK)",
        "Teknik Pangan (PG)"
      ];
    case 'Sekolah Arsitektur, Perencanaan dan Pengembangan Kebijakan (SAPPK)': 
      return [
        "Arsitektur (AR)",
        "Perencanaan Wilayah dan Kota (PWK)"
      ];
    case 'Sekolah Bisnis dan Manajemen (SBM)': 
      return [
        "Kewirausahaan (MK)",
        "Manajemen (MB)"
      ];
    case 'Sekolah Farmasi (SF)': 
      return [
        "Farmasi Klinik dan Komunitas (FKK)",
        "Sains dan Teknologi Farmasi (FA)"
      ];
    case 'Sekolah Ilmu dan Teknologi Hayati (SITH)': 
      return [
        "Biologi (BI)",
        "Mikrobiologi (BM)",
        "Rekayasa Hayati (BE)",
        "Rekayasa Pertanian (BA)",
        "Rekayasa Kehutanan (BW)",
        "Teknologi Pascapanen (BP)",
      ];
    case 'Sekolah Teknik Elektro dan Informatika (STEI)': 
      return [
        "Sistem dan Teknologi Informasi (II)",
        "Teknik Biomedis (EB)",
        "Teknik Elektro (EL)",
        "Informatika (IF)",
        "Teknik Telekomunikasi (ET)",
        "Teknik Tenaga Listrik (EP)"
      ];
    default: return [];
  }
}

Color? getColorFromSubmissionStatus(String? status) {
  return status == 'exported'
    ? Colors.green
    : status == 'pending'
      ? Colors.orange
      : status == 'unchecked'
        ? Colors.blue
        : status == 'spam'
          ? Colors.red
          : null;
}