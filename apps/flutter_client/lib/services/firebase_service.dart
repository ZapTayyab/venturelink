import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/config/app_config.dart';
import 'package:cloud_functions/cloud_functions.dart';
class FirebaseService {
  FirebaseService._();

  static Future<void> init() async {
  if (AppConfig.instance.useEmulator) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  }
}

  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> collection(String path) =>
      firestore.collection(path);

  static DocumentReference<Map<String, dynamic>> doc(String path) =>
      firestore.doc(path);

  static Future<String?> getIdToken({bool forceRefresh = false}) async {
    return auth.currentUser?.getIdToken(forceRefresh);
  }

  // Collection paths
  static const String usersCollection = 'users';
  static const String startupsCollection = 'startups';
  static const String fundingRoundsCollection = 'fundingRounds';
  static const String investmentsCollection = 'investments';
  static const String adminActionLogsCollection = 'adminActionLogs';
}