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
  String? field;
  late DateTime timestamp;
  
  LastUpdatedModel.fromJson(Map<String, dynamic> json) {
    field = json['field'];
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

class FakultasModel {
  late int id;
  late String name;
  List<ProgramStudiModel> programStudi = [];

  FakultasModel({
    required this.id,
    required this.name,
    required this.programStudi,
  });

  FakultasModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    List.of(json['program_studi']).forEach((v) => programStudi.add(ProgramStudiModel.fromJson(v)));
  }

  List<String> formatedProgramStudi() => programStudi.map((v) => v.name).toList();
}

class ProgramStudiModel {
  late int id;
  late String name;
  List<MataKuliahPraktikumModel> mataKuliah = [];
  List<MataKuliahPraktikumModel> praktikum = [];
  
  ProgramStudiModel({
    required this.id,
    required this.name,
    required this.mataKuliah,
    required this.praktikum,
  });

  ProgramStudiModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    List.of(json['mata_kuliah']).forEach((v) => mataKuliah.add(MataKuliahPraktikumModel.fromJson(v)));
    List.of(json['praktikum']).forEach((v) => praktikum.add(MataKuliahPraktikumModel.fromJson(v)));
  }

  List<String> formatedMataKuliah() => mataKuliah.map((v) => '${v.kode} ${v.nama}').toList();
  List<String> formatedPraktikum() => praktikum.map((v) => '${v.kode} ${v.nama}').toList();
}

class MataKuliahPraktikumModel {
  late int id;
  late String kode, nama;

  MataKuliahPraktikumModel({
    required this.id,
    required this.kode,
    required this.nama,
  });

  MataKuliahPraktikumModel.fromJson(Map<String, dynamic> json) {
    id = json['id']; 
    kode = json['kode']; 
    nama = json['nama']; 
  }
}

class UserPreferenceModel {
  bool remindPeminjamanPeralatan;
  bool remindSuratKeteranganPraktikum;
  bool remindPertukaranJadwal;
  
  UserPreferenceModel({
    this.remindPeminjamanPeralatan = true,
    this.remindSuratKeteranganPraktikum = true,
    this.remindPertukaranJadwal = true,
  });
}

class StorageCacheModel {
  GlobalConfigModel globalConfig;
  List<FakultasModel> fakultas;
  UserPreferenceModel userPreference;
  DateTime? lastSync;
  
  StorageCacheModel({
    required this.globalConfig,
    required this.fakultas,
    required this.lastSync,
    required this.userPreference
  });

  List<ProgramStudiModel> get programStudi => fakultas.expand((f) => f.programStudi).toList();
  List<MataKuliahPraktikumModel> get mataKuliah => programStudi.expand((p) => p.mataKuliah).toList();
  List<MataKuliahPraktikumModel> get praktikum => programStudi.expand((p) => p.praktikum).toList();

  List<String> formatedFakultas() => fakultas.map((v) => v.name).toList();
  List<String> formatedProgramStudi() => programStudi.map((v) => v.name).toList();
  List<String> formatedMataKuliah() => mataKuliah.map((v) => '${v.kode} ${v.nama}').toList();
  List<String> formatedPraktikum() => praktikum.map((v) => '${v.kode} ${v.nama}').toList();
}