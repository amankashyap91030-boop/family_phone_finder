import 'package:flutter/material.dart';
class RadarScannerScreen extends StatelessWidget {
  final dynamic targetDevice;
  const RadarScannerScreen({super.key, this.targetDevice});
  @override
  Widget build(BuildContext context) { return const Scaffold(body: Center(child: Text("Radar Scanner"))); }
}
