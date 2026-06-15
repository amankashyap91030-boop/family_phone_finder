// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'family_device.dart';

class FamilyDeviceAdapter extends TypeAdapter<FamilyDevice> {
  @override
  final int typeId = 0;

  @override
  FamilyDevice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FamilyDevice(
      id: fields[0] as String,
      name: fields[1] as String,
      bluetoothMacAddress: fields[2] as String,
      lastKnownLatitude: fields[3] as double,
      lastKnownLongitude: fields[4] as double,
      lastBatteryLevel: fields[5] as int,
      lastSeenTime: fields[6] as DateTime,
      isTargetModeActive: fields[7] as bool,
      customDeviceIcon: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FamilyDevice obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.bluetoothMacAddress)
      ..writeByte(3)
      ..write(obj.lastKnownLatitude)
      ..writeByte(4)
      ..write(obj.lastKnownLongitude)
      ..writeByte(5)
      ..write(obj.lastBatteryLevel)
      ..writeByte(6)
      ..write(obj.lastSeenTime)
      ..writeByte(7)
      ..write(obj.isTargetModeActive)
      ..writeByte(8)
      ..write(obj.customDeviceIcon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyDeviceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
