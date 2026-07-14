import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'controllers/zoness_controller.dart';
import 'core/current_location_device.dart';
import 'theme/app_theme.dart';
import 'services/app_state.dart';
import 'screens/root_shell.dart';


// 1. Mark main as async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('Checking location services at boot...');
    await Get.put(CurrentLocationDevice()); //get the location of device
  } catch (e) {
    print('⚠️ Boot-phase location initialization skipped: $e');
  }

  runApp(const MaritimeWatchApp());
}

class MaritimeWatchApp extends StatelessWidget {
  const MaritimeWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: GetMaterialApp(
        title: 'Maritime Watch',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AppRoot(),
      ),
    );
  }
}

