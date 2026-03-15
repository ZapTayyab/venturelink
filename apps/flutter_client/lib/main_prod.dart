import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'services/firebase_service.dart';
import 'services/functions_service.dart';

// firebase_options_prod.dart must be generated using:
// flutterfire configure --project=your-prod-project
// import 'core/config/firebase_options_prod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.init(
    environment: AppEnvironment.prod,
    firebaseProjectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
    functionsBaseUrl: const String.fromEnvironment('FUNCTIONS_BASE_URL'),
    useEmulator: false,
  );

  // Replace with production FirebaseOptions
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseService.init();
  await FunctionsService.init();

  runApp(const ProviderScope(child: VentureLinkApp()));
}