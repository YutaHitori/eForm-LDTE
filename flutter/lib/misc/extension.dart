import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

extension StringExtensions on String? {
  bool isBlank() {
    return this == null || this!.trim().isEmpty;
  }

  bool verifyPhone() {
    if (this == null) return false;
    String phone = this!.trim().replaceAll(' - ', '');
    return !(int.tryParse(phone) == null || phone.length < 10 || phone.length > 12);
  }

  DateTime? toDateTime() {
    return DateTime.tryParse((this ?? '').replaceAll('/', '-'));
  }
}

extension DateTimeExtension on DateTime {
  DateTime next(int day) {
    return this.add(
      Duration(days: (day - this.weekday + 7) % 7),
    );
  }

  String nextDateString(int day) {
    return this.next(day).toString().substring(0, 10).replaceAll('-', '/');
  }
  
  String toDateString() {
    return this.toString().substring(0,10).replaceAll('-', '/');
  }
}

extension DoubleExtension on double {
  double get cm => this * PdfPageFormat.cm;

  double get mm => this * PdfPageFormat.mm;
}

extension IntExtension on int {
  double get cm => this * PdfPageFormat.cm;

  double get mm => this * PdfPageFormat.mm;
}

extension TimeOfDayExtension on TimeOfDay {
  String toFormatedString() {
    return '${hour < 10 ? '0$hour' : hour}:${minute < 10 ? '0$minute' : minute}';
  }
}