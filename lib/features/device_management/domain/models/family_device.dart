import 'package:hive/hive.dart';

part 'family_device.g.dart';

@HiveType(typeId: 0)
class FamilyDevice extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final String bluetoothMacAddress;

  @HiveField(3)
  double lastKnownLatitude;

  @HiveField(4)
  double lastKnownLongitude;

  @HiveField(5)
  int lastBatteryLevel;

  @HiveField(6)
  DateTime lastSeenTime;

  @HiveField(7)
  bool isTargetModeActive;

  @HiveField(8)
  String customDeviceIcon;

  FamilyDevice({
    required this.id,
    required this.name,
    required this.bluetoothMacAddress,
    required this.lastKnownLatitude,
    required this.lastKnownLongitude,
    required this.lastBatteryLevel,
    required this.lastSeenTime,
    this.isTargetModeActive = false,
    required this.customDeviceIcon,
  });
}
