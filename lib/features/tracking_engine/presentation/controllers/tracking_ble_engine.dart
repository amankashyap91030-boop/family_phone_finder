import 'package:flutter_riverpod/flutter_riverpod.dart';
enum ZoneRange { unknown, far, near, immediate }
class BLETrackerState {
  final bool isScanning;
  final List<dynamic> scanResults;
  final ZoneRange range;
  final int smoothedRssi;
  BLETrackerState({this.isScanning = false, this.scanResults = const [], this.range = ZoneRange.unknown, this.smoothedRssi = -100});
}
class BLETrackerNotifier extends StateNotifier<BLETrackerState> {
  BLETrackerNotifier() : super(BLETrackerState());
  void startTargetTracking(String mac) {}
  void stopTracking() {}
}
final bleTrackerProvider = StateNotifierProvider<BLETrackerNotifier, BLETrackerState>((ref) => BLETrackerNotifier());
