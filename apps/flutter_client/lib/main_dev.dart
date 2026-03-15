import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'services/firebase_service.dart';
import 'services/functions_service.dart';
import 'services/blockchain_service.dart';
import 'core/config/firebase_options_dev.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.init(
    environment: AppEnvironment.dev,
    firebaseProjectId: 'venturelink-dev',
    functionsBaseUrl: 'http://localhost:5001',
    useEmulator: false,
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseService.init();
  await FunctionsService.init();

  // Initialize blockchain service
  // For student demo: generate a Sepolia wallet at https://vanity-eth.tk
  // Fund it with free ETH from https://sepoliafaucet.com
  // NEVER use a real mainnet wallet here
  await BlockchainService.init(
    privateKey: const String.fromEnvironment(
      'BLOCKCHAIN_PRIVATE_KEY',
      defaultValue: '0x0000000000000000000000000000000000000000000000000000000000000001',
    ),
  );

  runApp(const ProviderScope(child: VentureLinkApp()));
}