import 'package:cloud_functions/cloud_functions.dart';
import '../core/config/app_config.dart';
import '../core/errors/app_exception.dart';

class FunctionsService {
  FunctionsService._();

  static FirebaseFunctions get _functions => FirebaseFunctions.instance;

  static Future<void> init() async {
    if (AppConfig.instance.useEmulator) {
      FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    }
  }

  static Future<Map<String, dynamic>> call(
    String functionName, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final callable = _functions.httpsCallable(functionName);
      final result = await callable.call(data ?? {});
      return Map<String, dynamic>.from(result.data as Map);
    } on FirebaseFunctionsException catch (e) {
      throw AppException.fromFunctions(e);
    } catch (e) {
      throw AppException.unknown();
    }
  }

  // Named callable functions
  static Future<Map<String, dynamic>> createStartup(
          Map<String, dynamic> data) =>
      call('createStartup', data: data);

  static Future<Map<String, dynamic>> moderateStartup(
          Map<String, dynamic> data) =>
      call('moderateStartup', data: data);

  static Future<Map<String, dynamic>> createFundingRound(
          Map<String, dynamic> data) =>
      call('createFundingRound', data: data);

  static Future<Map<String, dynamic>> makeInvestment(
          Map<String, dynamic> data) =>
      call('makeInvestment', data: data);

  static Future<Map<String, dynamic>> getPlatformMetrics() =>
      call('getPlatformMetrics');
}