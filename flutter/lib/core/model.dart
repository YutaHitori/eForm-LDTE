import 'package:flutter/material.dart';

class SuratKeteranganPraktikumModel {
  late int id, modul;
  late String matkul, praktikum, bukti, status;
  late List<String> nama, nim;
  late DateTime date, createdAt;
  late TimeOfDay timeStart, timeEnd;

  SuratKeteranganPraktikumModel({
    required this.id,
    required this.nama,
    required this.nim,
    required this.matkul,
    required this.praktikum,
    required this.modul,
    required this.bukti,
    required this.date,
    required this.createdAt,
    required this.timeStart,
    required this.timeEnd,
    required this.status
  });

  SuratKeteranganPraktikumModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = List<String>.from(json['nama']);
    nim = List<String>.from(json['nim']);
    matkul = json['matkul'];
    praktikum = json['praktikum'];
    modul = json['modul'];
    bukti = json['bukti'];
    date = DateTime.parse(json['date']);
    createdAt = DateTime.parse(json['created_at']);
    List<String> ts = json['timeStart'].split(':');
    timeStart = TimeOfDay(hour: int.parse(ts[0]), minute: int.parse(ts[1]));
    List<String> te = json['timeEnd'].split(':');
    timeEnd = TimeOfDay(hour: int.parse(te[0]), minute: int.parse(te[1]));
    status = json['status'];
  }
}