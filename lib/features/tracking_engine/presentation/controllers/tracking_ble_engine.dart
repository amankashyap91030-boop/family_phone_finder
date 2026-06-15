import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum ZoneRange { unknown, far, near, immediate }

class BLETrackerState {
  final bool isScanning;
  final List<ScanResult> scanResults;
  final ZoneRange range;
  final int smoothedRssi;

  BLETrackerState({
    this.isScanning = false,
    this.scanResults = const [],
    this.range = ZoneRange.unknown,
    this.smoothedRssi = -100,
  });

  BLETrackerState copyWith({
    bool? isScanning,
    List<ScanResult>? scanResults,
    ZoneRange? range,
    int? smoothedRssi,
  }) {
    return BLETrackerState(
      isScanning: isScanning ?? this.isScanning,
      scanResults: scanResults ?? this.scanResults,
      range: range ?? this.range,
      smoothedRssi: smoothedRssi ?? this.smoothedRssi,
    );
  }
}

class BLETrackerNotifier extends StateNotifier<BLETrackerState> {
  BLETrackerNotifier() : super(BLETrackerState());

  StreamSubscription<List<ScanResult>>? _scanSubscription;

  Future<void> startTargetTracking(String macAddress) async {
    if (!await FlutterBluePlus.isSupported) return;

    state = state.copyWith(isScanning: true);

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      int targetRssi = -100;
      bool found = false;

      for (var result in results) {
        if (result.device.remoteId.str.toLowerCase() == macAddress.toLowerCase()) {
          targetRssi = result.rssi;
          found = true;
          break;
        }
      }

      ZoneRange estimatedRange = ZoneRange.unknown;
      if (found) {
        if (targetRssi > -60) {
          estimatedRange = ZoneRange.immediate;
        } else if (targetRssi > -80) {
          estimatedRange = ZoneRange.near;
        } else {
          estimatedRange = ZoneRange.far;
        }
      }

      state = state.copyWith(
        scanResults: results,
        smoothedRssi: targetRssi,
        range: estimatedRange,
      );
    });

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
    );
  }

  Future<void> stopTracking() async {
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    state = state.copyWith(isScanning: false, range: ZoneRange.unknown, smoothedRssi: -100);
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }
}

final bleTrackerProvider = StateNotifierProvider<BLETrackerNotifier, BLETrackerState>((ref) {
  return BLETrackerNotifier();
});
