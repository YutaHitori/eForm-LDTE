import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

extension StringNExtensions on String? {
  bool isBlank() {
    return this == null || this!.trim().isEmpty;
  }

  bool verifyPhone() {
    if (this == null) return false;
    String phone = this!.trim().replaceAll(' - ', '');
    return !(int.tryParse(phone) == null || phone.length < 10 || phone.length > 12);
  }

  DateTime? toDateTime() {
    return DateTime.tryParse((this?.trim() ?? '').replaceAll('/', '-'));
  }

  String capitalCase([bool retain = true]) => this?.capitalCase() ?? '';
}

extension StringExtensions on String {
  String capitalCase([bool retain = true]) => 
  replaceAll(RegExp(r'\s+'), ' ').split(' ').map((w) {
    if (w.isEmpty) return '';
    if (!retain) w = w.toLowerCase();
    return w[0].toUpperCase() + w.substring(1);
  }).join(' ').replaceAll(' Dan ', ' dan ');
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
    return DateFormat('dd/MM/yyyy HH:mm:ss', 'id_ID').format(this);
  }

  String toDateFormatString() {
    return DateFormat('EEEE / dd MMMM yyyy', 'id_ID').format(this);
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

extension UriExtension on Uri {
  Map<String, Object?> get queryParametersAllFormated => 
    queryParametersAll.map(
      (key, value) => 
        MapEntry(
          key, 
          value.isEmpty 
            ? null 
            : value.length == 1 
              ? value.first 
              : value
        )
    ); 
}