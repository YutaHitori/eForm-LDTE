import 'package:flutter/material.dart';

class PeminjamanPeralatanModel {
  late int id;
  late String nama, nim, status;
  late List<String> barang;
  late List<int> banyak;
  late DateTime mulai, akhir, createdAt;

  PeminjamanPeralatanModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
    nim = json['nim'];
    mulai = DateTime.parse(json['mulai']);
    akhir = DateTime.parse(json['akhir']);
    barang = List<String>.from(json['barang']);
    banyak = List<int>.from(json['banyak']);
    createdAt = DateTime.parse(json['created_at']);
    status = json['status'];
  }

  List<String> banyakBarang() {
    return List.generate(barang.length, (i) => '${barang[i]} x${banyak[i]}');
  }
} 

class SuratKeteranganPraktikumModel {
  late int id, modul;
  late String matkul, praktikum, bukti, status;
  late List<String> nama, nim;
  late DateTime date, createdAt;
  late TimeOfDay timeStart, timeEnd;

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

class LastUpdatedModel {
  String? fakultas, type;
  DateTime? timestamp;
  
  LastUpdatedModel.fromJson(Map<String, dynamic> json) {
    fakultas = json['fakultas'];
    type = json['type'];
    timestamp = DateTime.parse(json['updated_at']);
  }
}

class GlobalConfigModel {
  String? nomorSurat;
  String? lineOALDTE;

  GlobalConfigModel({
    this.nomorSurat,
    this.lineOALDTE,
  });

  GlobalConfigModel.fromJson(Map<String, dynamic> json) {
    nomorSurat = json['nomor_surat'];
    lineOALDTE = json['lineoa_ldte'];
  }
}

class MataKuliahPraktikumModel {
  late String fakultas, programStudi, kode, nama;
  late bool isPraktikum;

  MataKuliahPraktikumModel({
    required this.fakultas,
    required this.programStudi,
    required this.kode,
    required this.nama,
    required this.isPraktikum,
  });

  MataKuliahPraktikumModel.fromJson(Map<String, dynamic> json) {
    fakultas = json['fakultas']; 
    programStudi = json['program_studi']; 
    kode = json['kode']; 
    nama = json['nama']; 
    isPraktikum = json['is_praktikum']; 
  }
}

class StorageCacheModel {
  GlobalConfigModel globalConfig;
  List<MataKuliahPraktikumModel> mataKuliahPraktikum;
  DateTime? lastSync;
  
  StorageCacheModel({
    required this.globalConfig,
    required this.mataKuliahPraktikum,
    required this.lastSync,
  });

  List<MataKuliahPraktikumModel> get mataKuliah => mataKuliahPraktikum.where((v) => !v.isPraktikum).toList();
  List<MataKuliahPraktikumModel> get praktikum => mataKuliahPraktikum.where((v) => v.isPraktikum).toList();

  List<MataKuliahPraktikumModel> byFakultas(String fakultas) {
    return mataKuliahPraktikum.where((v) => v.fakultas == fakultas).toList();
  }

  List<MataKuliahPraktikumModel> byProgramStudi(String programStudi) {
    return mataKuliahPraktikum.where((v) => v.programStudi == programStudi).toList();
  }

  MataKuliahPraktikumModel? byKode(String kode) {
    return mataKuliahPraktikum.where((v) => v.kode == kode).firstOrNull;
  }

  List<String> formatedMataKuliah() {
    List<String> temp = [];
    mataKuliah.forEach((v) => temp.add('${v.kode} ${v.nama}'));
    return temp;
  }

  List<String> formatedPraktikum() {
    List<String> temp = [];
    praktikum.forEach((v) => temp.add('${v.kode} ${v.nama}'));
    return temp;
  }
}