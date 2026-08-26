import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  String? field, reference;
  late DateTime timestamp;
  
  LastUpdatedModel.fromJson(Map<String, dynamic> json) {
    field = json['field'];
    reference = json['reference'];
    timestamp = DateTime.parse(json['updated_at']);
  }
}

class GlobalConfigModel {
  String? nomorSurat, lineOALDTE, namaKepalaLDTE, nipKepalaLDTE, caraPinjam, caraKeterangan, caraPertukaran, caraIzin;

  GlobalConfigModel({
    this.nomorSurat,
    this.lineOALDTE,
    this.namaKepalaLDTE,
    this.nipKepalaLDTE,
    this.caraPinjam,
    this.caraKeterangan,
    this.caraPertukaran,
    this.caraIzin
  });

  GlobalConfigModel.fromJson(Map<String, dynamic> json) {
    nomorSurat = json['nomor_surat'];
    lineOALDTE = (json['lineoa_ldte'] as String).trim();
    namaKepalaLDTE = (json['nama_kepala_ldte'] as String).trim();
    nipKepalaLDTE = (json['nip_kepala_ldte'] as String).trim();
    caraPinjam = (json['cara_pinjam'] as String).trim();
    caraKeterangan = (json['cara_keterangan'] as String).trim();
    caraPertukaran = (json['cara_pertukaran'] as String).trim();
    caraIzin = (json['cara_izin'] as String).trim();
  }

  GlobalConfigModel duplicate() => GlobalConfigModel(
    nomorSurat: nomorSurat,
    lineOALDTE: lineOALDTE,
    namaKepalaLDTE: namaKepalaLDTE,
    nipKepalaLDTE: nipKepalaLDTE,
    caraPinjam: caraPinjam,
    caraKeterangan: caraKeterangan,
    caraPertukaran: caraPertukaran,
    caraIzin: caraIzin,
  );
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
    if (json['program_studi'] != null) programStudi = List.from(json['program_studi']).map((v) => ProgramStudiModel.fromJson(v, name)).toList();
  }

  FakultasModel duplicate() => FakultasModel(
    id: id, 
    name: name, 
    programStudi: programStudi.map((v) => v.duplicate()).toList()
  );

  List<String> formatedProgramStudi() => programStudi.map((v) => v.name).toList();
  bool isEqualTo(FakultasModel ref) => id == ref.id && name == ref.name;
}

class ProgramStudiModel {
  late int id;
  late String name, fakultas;
  late List<MatprakModel> matprak = [];

  List<MatprakModel> get mataKuliah => matprak.where((v) => v.isPraktikum != true).toList();
  List<MatprakModel> get praktikum => matprak.where((v) => v.isPraktikum != false).toList();
  
  ProgramStudiModel({
    required this.id,
    required this.name,
    required this.fakultas,
    required this.matprak,
  });

  ProgramStudiModel.fromJson(Map<String, dynamic> json, [String? fakultasName]) {
    id = json['id'];
    name = json['name'];
    fakultas = fakultasName ?? json['fakultas'];
    if (json['mata_kuliah'] != null) List.from(json['mata_kuliah']).forEach((v) => matprak.add(MatprakModel.fromJson(v, name)));
  }

  List<String> formatedMataKuliah() => mataKuliah.map((v) => '${v.kode} ${v.nama}').toList();
  List<String> formatedPraktikum() => praktikum.map((v) => '${v.kode} ${v.nama}').toList();

  ProgramStudiModel duplicate() => ProgramStudiModel(
    id: id,
    name: name,
    fakultas: fakultas,
    matprak: matprak.map((v) => v.duplicate()).toList(),
  );

  bool isEqualTo(ProgramStudiModel ref) => id == ref.id && name == ref.name && fakultas == ref.fakultas;
}

class MatprakModel {
  late int id;
  late String kode, nama, programStudi;
  bool? isPraktikum;

  String get type => isPraktikum == null ? 'keduanya' : isPraktikum! ? 'praktikum' : 'mata kuliah';

  MatprakModel({
    required this.id,
    required this.kode,
    required this.nama,
    required this.programStudi,
    required this.isPraktikum,
  });

  MatprakModel.fromJson(Map<String, dynamic> json, [String? programStudiName]) {
    id = json['id']; 
    kode = (json['kode'] as String).trim().toUpperCase(); 
    nama = (json['nama'] as String).trim(); 
    programStudi = programStudiName ?? json['program_studi']; 
    isPraktikum = json['is_praktikum']; 
  }

  MatprakModel duplicate() => MatprakModel(
    id: id,
    kode: kode,
    nama: nama,
    programStudi: programStudi,
    isPraktikum: isPraktikum,
  );

  bool isEqualTo(MatprakModel ref) => id == ref.id && kode == ref.kode && nama == ref.nama && programStudi == ref.programStudi && isPraktikum == ref.isPraktikum;
}

class UserPreferenceModel {
  bool remindPeminjamanPeralatan;
  bool remindSuratKeteranganPraktikum;
  bool remindPertukaranJadwal;
  bool remindSuratKeteranganIzin;
  
  UserPreferenceModel({
    this.remindPeminjamanPeralatan = true,
    this.remindSuratKeteranganPraktikum = true,
    this.remindPertukaranJadwal = true,
    this.remindSuratKeteranganIzin = true,
  });

  UserPreferenceModel duplicate() => UserPreferenceModel(
    remindPeminjamanPeralatan: remindPeminjamanPeralatan,
    remindSuratKeteranganPraktikum: remindSuratKeteranganPraktikum,
    remindPertukaranJadwal: remindPertukaranJadwal,
    remindSuratKeteranganIzin: remindSuratKeteranganIzin,
  );
}

class ItemModel {
  late int id;
  late String name;
  
  ItemModel({
    required this.id,
    required this.name,
  });

  ItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  bool isEqualTo(ItemModel ref) => id == ref.id && name == ref.name;

  ItemModel duplicate() => ItemModel(
    id: id,
    name: name,
  );
}

class StorageCacheModel {
  GlobalConfigModel globalConfig;
  List<FakultasModel> fakultas;
  List<ItemModel> item;
  UserPreferenceModel userPreference;
  DateTime? lastSync;
  
  StorageCacheModel({
    required this.globalConfig,
    required this.fakultas,
    required this.userPreference,
    required this.lastSync,
    required this.item,
  });
  
  // List<({FakultasModel fakultas, MatprakModel matprak, ProgramStudiModel programStudi})> get _flattened => 
  // fakultas.expand((a) {
  //   return a.programStudi.expand((b) {
  //     return b.matprak.map((c) => (matprak: c, programStudi: b, fakultas: a));
  //   });
  // }).toList();

  // List<ProgramStudiModel> get programStudi => _flattened.map((v) => v.programStudi).toSet().toList();
  // List<MatprakModel> get matprak => _flattened.map((p) => p.matprak).toSet().toList();
  // List<MatprakModel> get mataKuliah => matprak.where((v) => v.isPraktikum != true).toList();
  // List<MatprakModel> get praktikum => matprak.where((v) => v.isPraktikum != false).toList();

  List<ProgramStudiModel> get programStudi => fakultas.expand((f) => f.programStudi).toList();
  List<MatprakModel> get matprak => programStudi.expand((p) => p.matprak).toList();
  List<MatprakModel> get mataKuliah => programStudi.expand((p) => p.mataKuliah).toList();
  List<MatprakModel> get praktikum => programStudi.expand((p) => p.praktikum).toList();

  List<String> formatedFakultas([bool lowerCase = false]) => fakultas.map((v) => lowerCase ? v.name.toLowerCase() : v.name).toList();
  List<String> formatedProgramStudi([bool lowerCase = false]) => programStudi.map((v) => lowerCase ? v.name.toLowerCase() : v.name).toList();
  List<String> formatedMataKuliah([bool lowerCase = false]) => mataKuliah.map((v) => lowerCase ? '${v.kode} ${v.nama}'.toLowerCase() : '${v.kode} ${v.nama}').toList();
  List<String> formatedPraktikum([bool lowerCase = false]) => praktikum.map((v) => lowerCase ? '${v.kode} ${v.nama}'.toLowerCase() : '${v.kode} ${v.nama}').toList();
  List<String> formatedMatprak([bool lowerCase = false]) => matprak.map((v) => lowerCase ? '${v.kode} ${v.nama}'.toLowerCase() : '${v.kode} ${v.nama}').toList();

  List<String> formatedItem([bool lowerCase = false]) => item.map((v) => lowerCase ? v.name.toLowerCase() : v.name).toList();

  FakultasModel? getFakultas(String name) => fakultas.firstWhereOrNull((v) => v.name == name);
  ProgramStudiModel? getProgramStudi(String name) => programStudi.firstWhereOrNull((v) => v.name == name);
  ProgramStudiModel? getProgramStudiFromMatprak(MatprakModel model) => programStudi.firstWhereOrNull((v) => v.matprak.any((v) => v.id == model.id));

  void removeWhere<T>(bool Function(dynamic) test) {
    if (T == ItemModel) {
      item.removeWhere(test as bool Function(ItemModel element));
    } else if (T == FakultasModel) {
      fakultas.removeWhere(test as bool Function(FakultasModel element));
    } else {
      for (var f in fakultas) {
        if (T == ProgramStudiModel) {
          f.programStudi.removeWhere(test as bool Function(ProgramStudiModel element));
        } else {
          for (var p in f.programStudi) {
            p.matprak.removeWhere(test as bool Function(MatprakModel element));
          }
        }
      }
    }
  }

  StorageCacheModel duplicate() => StorageCacheModel(
    globalConfig: globalConfig.duplicate(),
    fakultas: fakultas.map((v) => v.duplicate()).toList(),
    userPreference: userPreference.duplicate(),
    lastSync: lastSync,
    item: item.map((v) => v.duplicate()).toList()
  );
}

class QueueActionModel {
  Set<int> insert = <int>{};
  Set<int> update = <int>{};
  Set<int> delete = <int>{};
  Set<int> loading = <int>{};
  Set<int> select = <int>{};

  QueueActionModel({
    Set<int>? insert,
    Set<int>? update,
    Set<int>? delete,
  }) {
    this.insert = insert ?? <int>{};
    this.update = update ?? <int>{};
    this.delete = delete ?? <int>{};
  }

  Set<int> get set => {...insert, ...update, ...delete};
  bool get isAnyQueued => set.isNotEmpty;
  bool contains(int id, [bool isLoading = false]) => set.difference(isLoading ? loading : {}).contains(id);
}