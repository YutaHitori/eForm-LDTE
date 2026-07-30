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
      fakultas: fields[0] as String,
      programStudi: fields[1] as String,
      kode: fields[2] as String,
      nama: fields[3] as String,
      isPraktikum: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MataKuliahPraktikumModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.fakultas)
      ..writeByte(1)
      ..write(obj.programStudi)
      ..writeByte(2)
      ..write(obj.kode)
      ..writeByte(3)
      ..write(obj.nama)
      ..writeByte(4)
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
      mataKuliahPraktikum: (fields[7] as List).cast<MataKuliahPraktikumModel>(),
      lastSync: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, StorageCacheModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(5)
      ..write(obj.lastSync)
      ..writeByte(6)
      ..write(obj.globalConfig)
      ..writeByte(7)
      ..write(obj.mataKuliahPraktikum);
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
    );
  }

  @override
  void write(BinaryWriter writer, GlobalConfigModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.nomorSurat)
      ..writeByte(1)
      ..write(obj.lineOALDTE);
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
