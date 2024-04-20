// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PremiumAdapter extends TypeAdapter<Premium> {
  @override
  final int typeId = 3;

  @override
  Premium read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Premium(
      ispremium: fields[0] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Premium obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.ispremium);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremiumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
