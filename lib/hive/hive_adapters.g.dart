// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class MataKuliahPraktikumModelAdapter
    extends TypeAdapter<MataKuliahPraktikumModel> {
  @override
  final typeId = 0;

  @override
  MataKuliahPraktikumModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MataKuliahPraktikumModel(
      id: (fields[5] as num).toInt(),
      kode: fields[2] as String,
      nama: fields[3] as String,
      isPraktikum: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MataKuliahPraktikumModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(2)
      ..write(obj.kode)
      ..writeByte(3)
      ..write(obj.nama)
      ..writeByte(5)
      ..write(obj.id)
      ..writeByte(6)
      ..write(obj.isPraktikum);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MataKuliahPraktikumModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StorageCacheModelAdapter extends TypeAdapter<StorageCacheModel> {
  @override
  final typeId = 1;

  @override
  StorageCacheModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StorageCacheModel(
      globalConfig: fields[6] as GlobalConfigModel,
      fakultas: (fields[9] as List).cast<FakultasModel>(),
      lastSync: fields[5] as DateTime?,
      userPreference: fields[8] as UserPreferenceModel,
    );
  }

  @override
  void write(BinaryWriter writer, StorageCacheModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(5)
      ..write(obj.lastSync)
      ..writeByte(6)
      ..write(obj.globalConfig)
      ..writeByte(8)
      ..write(obj.userPreference)
      ..writeByte(9)
      ..write(obj.fakultas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageCacheModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GlobalConfigModelAdapter extends TypeAdapter<GlobalConfigModel> {
  @override
  final typeId = 2;

  @override
  GlobalConfigModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GlobalConfigModel(
      nomorSurat: fields[0] as String?,
      lineOALDTE: fields[1] as String?,
    )..fakultas = fields[2] as DateTime;
  }

  @override
  void write(BinaryWriter writer, GlobalConfigModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.nomorSurat)
      ..writeByte(1)
      ..write(obj.lineOALDTE)
      ..writeByte(2)
      ..write(obj.fakultas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlobalConfigModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserPreferenceModelAdapter extends TypeAdapter<UserPreferenceModel> {
  @override
  final typeId = 3;

  @override
  UserPreferenceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferenceModel(
      remindPeminjamanPeralatan: fields[0] == null ? true : fields[0] as bool,
      remindSuratKeteranganPraktikum: fields[1] == null
          ? true
          : fields[1] as bool,
      remindPertukaranJadwal: fields[2] == null ? true : fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferenceModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.remindPeminjamanPeralatan)
      ..writeByte(1)
      ..write(obj.remindSuratKeteranganPraktikum)
      ..writeByte(2)
      ..write(obj.remindPertukaranJadwal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferenceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FakultasModelAdapter extends TypeAdapter<FakultasModel> {
  @override
  final typeId = 4;

  @override
  FakultasModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FakultasModel(
      id: (fields[0] as num).toInt(),
      name: fields[1] as String,
      programStudi: (fields[2] as List).cast<ProgramStudiModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, FakultasModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.programStudi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FakultasModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgramStudiModelAdapter extends TypeAdapter<ProgramStudiModel> {
  @override
  final typeId = 5;

  @override
  ProgramStudiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgramStudiModel(
      id: (fields[0] as num).toInt(),
      name: fields[1] as String,
      mataKuliahPraktikum: (fields[4] as List).cast<MataKuliahPraktikumModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProgramStudiModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.mataKuliahPraktikum);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramStudiModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
