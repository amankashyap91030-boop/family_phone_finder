import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'core/theme/dark_theme.dart';
import 'features/device_management/domain/models/family_device.dart';
import 'features/device_management/presentation/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Directory appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  Hive.registerAdapter(FamilyDeviceAdapter());
  await Hive.openBox<FamilyDevice>('trusted_devices_box');

  runApp(
    const ProviderScope(
      child: FamilyPhoneFinderApp(),
    ),
  );
}

class FamilyPhoneFinderApp extends StatelessWidget {
  const FamilyPhoneFinderApp({Key? super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Phone Finder',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: darkTheme,
      home: const FamilyDashboardScreen(),
    );
  }
}
