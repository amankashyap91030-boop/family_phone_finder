import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/family_device.dart';
import '../../../tracking_engine/presentation/screens/radar_scanner_screen.dart';

class FamilyDashboardScreen extends ConsumerWidget {
  const FamilyDashboardScreen({Key? super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<FamilyDevice> trustedFamilyNetwork = [
      FamilyDevice(id: '1', name: "Mom's Phone", bluetoothMacAddress: "A0:B1:C2:D3:E4:F5", lastKnownLatitude: 28.6139, lastKnownLongitude: 77.2090, lastBatteryLevel: 94, lastSeenTime: DateTime.now(), customDeviceIcon: "mom"),
      FamilyDevice(id: '2', name: "Dad's Phone", bluetoothMacAddress: "F5:E4:D3:C2:B1:A0", lastKnownLatitude: 28.6142, lastKnownLongitude: 77.2094, lastBatteryLevel: 14, lastSeenTime: DateTime.now().subtract(const Duration(minutes: 4)), customDeviceIcon: "dad"),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Network Dashboard'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text("PAIRED INDOOR DEVICES", style: TextStyle(color: Colors.white38, letterSpacing: 1.5, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: trustedFamilyNetwork.length,
                  itemBuilder: (context, index) {
                    final device = trustedFamilyNetwork[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: GlassmorphicCard(
                        device: device,
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RadarScannerScreen(targetDevice: device)),
                          );
                        },
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class GlassmorphicCard extends StatelessWidget {
  final FamilyDevice device;
  final VoidCallback onPress;

  const GlassmorphicCard({required this.device, required this.onPress, Key? super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF6C63FF).withOpacity(0.15),
              child: const Icon(Icons.phone_android_rounded, color: Color(0xFF9D96FF)),
            ),
            title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
            subtitle: Padding(
              padding: const EdgeInsets.top(8.0),
              child: Row(
                children: [
                  Icon(Icons.battery_3_bar_rounded, size: 16, color: device.lastBatteryLevel < 20 ? Colors.redAccent : Colors.greenAccent),
                  const SizedBox(width: 4),
                  Text("${device.lastBatteryLevel}%", style: const TextStyle(color: Colors.white60)),
                  const SizedBox(width: 16),
                  const Icon(Icons.blur_on_rounded, size: 16, color: Colors.blueAccent),
                  const SizedBox(width: 4),
                  const Text("BLE Guard Active", style: TextStyle(color: Colors.white60)),
                ],
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
            onTap: onPress,
          ),
        ),
      ),
    );
  }
}
