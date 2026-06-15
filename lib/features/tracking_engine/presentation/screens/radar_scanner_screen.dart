import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/tracking_ble_engine.dart';

class RadarScannerScreen extends ConsumerStatefulWidget {
  final dynamic targetDevice;
  const RadarScannerScreen({super.key, this.targetDevice});

  @override
  ConsumerState<RadarScannerScreen> createState() => _RadarScannerScreenState();
}

class _RadarScannerScreenState extends ConsumerState<RadarScannerScreen> {
  @override
  void initState() {
    super.initState();
    // Jaise hi screen khule, tracking shuru ho jaye
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.targetDevice != null) {
         ref.read(bleTrackerProvider.notifier).startTargetTracking(widget.targetDevice.bluetoothMacAddress);
      }
    });
  }

  @override
  void dispose() {
    // Screen band hone par tracking ruk jaye
    ref.read(bleTrackerProvider.notifier).stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bleState = ref.watch(bleTrackerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Active Radar"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Zone Estimation: ${bleState.range.name.toUpperCase()}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 15),
            Text(
              "Signal Strength (RSSI): ${bleState.smoothedRssi} dBm",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            
            // Radar Icon jo signal ke hisaab se rang badlega
            if (bleState.range == ZoneRange.immediate)
               const Icon(Icons.check_circle, color: Colors.greenAccent, size: 100)
            else if (bleState.range == ZoneRange.near)
               const Icon(Icons.wifi_tethering, color: Colors.orangeAccent, size: 100)
            else if (bleState.range == ZoneRange.far)
               const Icon(Icons.wifi_tethering_off, color: Colors.redAccent, size: 100)
            else
               const Icon(Icons.search, color: Colors.grey, size: 100),
               
            const SizedBox(height: 20),
            Text(
              bleState.isScanning ? "Scanning for device..." : "Scanner Paused",
              style: const TextStyle(color: Colors.white54),
            )
          ],
        ),
      ),
    );
  }
}
