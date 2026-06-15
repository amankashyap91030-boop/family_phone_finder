import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum ProximityRange { veryClose, close, nearby, farAway, unknown }

class BLETrackerState {
  final int rawRssi;
  final int smoothedRssi;
  final ProximityRange range;
  final bool isScanning;

  BLETrackerState({
    required this.rawRssi,
    required this.smoothedRssi,
    required this.range,
    required this.isScanning,
  });

  factory BLETrackerState.initial() => BLETrackerState(
        rawRssi: -100,
        smoothedRssi: -100,
        range: ProximityRange.unknown,
        isScanning: false,
      );

  BLETrackerState copyWith({
    int? rawRssi,
    int? smoothedRssi,
    ProximityRange? range,
    bool? isScanning,
  }) {
    return BLETrackerState(
      rawRssi: rawRssi ?? this.rawRssi,
      smoothedRssi: smoothedRssi ?? this.smoothedRssi,
      range: range ?? this.range,
      isScanning: isScanning ?? this.isScanning,
    );
  }
}

class BLETrackerNotifier extends StateNotifier<BLETrackerState> {
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  final List<int> _rssiWindow = [];
  static const int windowSize = 6;

  BLETrackerNotifier() : super(BLETrackerState.initial());

  void startTargetTracking(String targetMacAddress) async {
    await _scanSubscription?.cancel();
    _rssiWindow.clear();

    if (!await FlutterBluePlus.isSupported) return;

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.remoteId.str.toLowerCase() == targetMacAddress.toLowerCase()) {
          _processIncomingRssi(result.rssi);
        }
      }
    });

    state = state.copyWith(isScanning: true);
    await FlutterBluePlus.startScan(continuous: true, androidUsesFineLocation: true);
  }

  void _processIncomingRssi(int newRssi) {
    if (_rssiWindow.length >= windowSize) {
      _rssiWindow.removeAt(0);
    }
    _rssiWindow.add(newRssi);

    int sum = _rssiWindow.reduce((a, b) => a + b);
    int smoothValue = (sum / _rssiWindow.length).round();

    ProximityRange computedRange;
    if (smoothValue >= -62) {
      computedRange = ProximityRange.veryClose;
    } else if (smoothValue >= -76) {
      computedRange = ProximityRange.close;
    } else if (smoothValue >= -88) {
      computedRange = ProximityRange.nearby;
    } else {
      computedRange = ProximityRange.farAway;
    }

    state = state.copyWith(
      rawRssi: newRssi,
      smoothedRssi: smoothValue,
      range: computedRange,
    );
  }

  void stopTracking() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    state = BLETrackerState.initial();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}

final bleTrackerProvider = StateNotifierProvider<BLETrackerNotifier, BLETrackerState>((ref) {
  return BLETrackerNotifier();
});
