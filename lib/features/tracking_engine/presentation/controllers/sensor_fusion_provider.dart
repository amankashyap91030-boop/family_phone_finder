import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'tracking_ble_engine.dart';

enum DirectionIndicator { heatingUp, coolingDown, stagnant }

class SensorFusionState {
  final double currentHeading;
  final DirectionIndicator indicator;
  final double vectorDelta;

  SensorFusionState({
    required this.currentHeading,
    required this.indicator,
    required this.vectorDelta,
  });

  factory SensorFusionState.initial() => SensorFusionState(
        currentHeading: 0.0,
        indicator: DirectionIndicator.stagnant,
        vectorDelta: 0.0,
      );
}

class SensorFusionNotifier extends StateNotifier<SensorFusionState> {
  final Ref _ref;
  StreamSubscription<CompassEvent>? _compassSubscription;
  int _lastProcessedRssi = -100;
  double _lastHeading = 0.0;

  SensorFusionNotifier(this._ref) : super(SensorFusionState.initial()) {
    _initSensorFusionStream();
  }

  void _initSensorFusionStream() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      final heading = event.heading ?? 0.0;
      _evaluateSpatialVector(heading);
    });
  }

  void _evaluateSpatialVector(double currentHeading) {
    final bleState = _ref.read(bleTrackerProvider);
    final int currentSmoothRssi = bleState.smoothedRssi;

    if (currentSmoothRssi == -100) return;

    DirectionIndicator relativeDirection = DirectionIndicator.stagnant;
    int rssiDelta = currentSmoothRssi - _lastProcessedRssi;

    if (rssiDelta > 1) {
      relativeDirection = DirectionIndicator.heatingUp;
    } else if (rssiDelta < -1) {
      relativeDirection = DirectionIndicator.coolingDown;
    } else {
      relativeDirection = state.indicator;
    }

    _lastProcessedRssi = currentSmoothRssi;
    _lastHeading = currentHeading;

    state = SensorFusionState(
      currentHeading: currentHeading,
      indicator: relativeDirection,
      vectorDelta: rssiDelta.toDouble(),
    );
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }
}

final sensorFusionProvider = StateNotifierProvider<SensorFusionNotifier, SensorFusionState>((ref) {
  return SensorFusionNotifier(ref);
});
