import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../device_management/domain/models/family_device.dart';
import '../controllers/tracking_ble_engine.dart';
import '../controllers/sensor_fusion_provider.dart';
import '../../../emergency_action/data/datasources/hardware_override_ds.dart';

class RadarScannerScreen extends ConsumerStatefulWidget {
  final FamilyDevice targetDevice;
  const RadarScannerScreen({required this.targetDevice, Key? super.key});

  @override
  ConsumerState<RadarScannerScreen> createState() => _RadarScannerScreenState();
}

class _RadarScannerScreenState extends ConsumerState<RadarScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _radarLoopController;
  final HardwareOverrideEngine _overrideEngine = HardwareOverrideEngine();
  bool _isForcedRinging = false;

  @override
  void initState() {
    super.initState();
    _radarLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bleTrackerProvider.notifier).startTargetTracking(widget.targetDevice.bluetoothMacAddress);
    });
  }

  @override
  void dispose() {
    _radarLoopController.dispose();
    _overrideEngine.resetHardwareSequence();
    super.dispose();
  }

  void _toggleEmergencyAlert() async {
    setState(() {
      _isForcedRinging = !_isForcedRinging;
    });
    if (_isForcedRinging) {
      await _overrideEngine.triggerEmergencySequence();
    } else {
      await _overrideEngine.resetHardwareSequence();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bleState = ref.watch(bleTrackerProvider);
    final fusionState = ref.watch(sensorFusionProvider);

    Color hotColdColor = Colors.white24;
    String semanticHeader = "Initializing Sensor Arrays...";

    if (fusionState.indicator == DirectionIndicator.heatingUp) {
      hotColdColor = Colors.redAccent;
      semanticHeader = "SIGNAL INCREASING: Getting Closer!";
    } else if (fusionState.indicator == DirectionIndicator.coolingDown) {
      hotColdColor = Colors.blueAccent;
      semanticHeader = "SIGNAL DECREASING: Wrong Direction!";
    }

    return Scaffold(
      appBar: AppBar(title: Text("Tracking ${widget.targetDevice.name}")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(semanticHeader, style: TextStyle(color: hotColdColor, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 36),
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _radarLoopController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CustomRadarPainter(_radarLoopController.value),
                      size: const Size(280, 280),
                    );
                  },
                ),
                Transform.rotate(
                  angle: (fusionState.currentHeading * math.pi / 180),
                  child: const Icon(Icons.navigation_rounded, size: 72, color: Color(0xFF6C63FF)),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Chip(
              backgroundColor: Colors.white10,
              label: Text(
                "Zone Estimation: ${bleState.range.name.toUpperCase()}",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isForcedRinging ? Colors.red : const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: Icon(_isForcedRinging ? Icons.volume_off : Icons.volume_up, color: Colors.white),
              label: Text(_isForcedRinging ? "SILENCE ALERT" : "FORCE EMERGENCY RING", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: _toggleEmergencyAlert,
            )
          ],
        ),
      ),
    );
  }
}

class CustomRadarPainter extends CustomPainter {
  final double pulseValue;
  CustomRadarPainter(this.pulseValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final strokePaint = Paint()
      ..color = const Color(0xFF6C63FF).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, maxRadius * 0.33, strokePaint);
    canvas.drawCircle(center, maxRadius * 0.66, strokePaint);
    canvas.drawCircle(center, maxRadius, strokePaint);

    final sweepGradientPaint = Paint()
      ..shader = SweepGradient(
        colors: [const Color(0xFF6C63FF).withOpacity(0.5), Colors.transparent],
        stops: const [0.0, 0.2],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(pulseValue * 2 * math.pi);
    canvas.drawCircle(Offset.zero, maxRadius, sweepGradientPaint..style = PaintingStyle.fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
