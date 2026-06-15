import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BLETrackerState {
  final bool isScanning;
  final List<dynamic> scanResults;
  BLETrackerState({this.isScanning = false, this.scanResults = const []});
  BLETrackerState copyWith({bool? isScanning, List<dynamic>? scanResults}) {
    return BLETrackerState(
      isScanning: isScanning ?? this.isScanning,
      scanResults: scanResults ?? this.scanResults,
    );
  }
}

class BLETrackerNotifier extends StateNotifier<BLETrackerState> {
  BLETrackerNotifier() : super(BLETrackerState());
  Future<void> startTracking() async {
    state = state.copyWith(isScanning: true);
  }
  Future<void> stopTracking() async {
    state = state.copyWith(isScanning: false);
  }
}

final bleTrackerProvider = StateNotifierProvider<BLETrackerNotifier, BLETrackerState>((ref) {
  return BLETrackerNotifier();
});
