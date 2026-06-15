import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLETrackerState {
  final bool isScanning;
  final List<ScanResult> scanResults;

  BLETrackerState({this.isScanning = false, this.scanResults = const []});

  BLETrackerState copyWith({bool? isScanning, List<ScanResult>? scanResults}) {
    return BLETrackerState(
      isScanning: isScanning ?? this.isScanning,
      scanResults: scanResults ?? this.scanResults,
    );
  }
}

class BLETrackerNotifier extends StateNotifier<BLETrackerState> {
  BLETrackerNotifier() : super(BLETrackerState());

  StreamSubscription<List<ScanResult>>? _scanSubscription;

  Future<void> startTracking() async {
    if (!await FlutterBluePlus.isSupported) return;

    state = state.copyWith(isScanning: true);

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      state = state.copyWith(scanResults: results);
    });

    // Modern FlutterBluePlus syntax for standard compatibility
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
    );
  }

  Future<void> stopTracking() async {
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    state = state.copyWith(isScanning: false);
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
