import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    return toString().substring(0,10).replaceAll('-', '/');
  }

  String toDateTimeFormatedString() {
    return DateFormat('EEEE, dd/MM/yyyy - HH:mm', 'id_ID').format(this);
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

extension ListExtension on List {
  String toFormatedString() {
    return '$this'.substring(1, '$this'.length - 1);
  }
}