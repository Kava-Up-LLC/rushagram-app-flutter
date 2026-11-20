import 'dart:convert';

import 'package:appambit_sdk_flutter/appambit_cloud_code.dart';

import '../errors.dart';

/// AppAmbit Cloud Code: today, start_run, submit_guess, ranking. The phone never talks to the database.
abstract interface class CloudService {
  Future<Map<String, dynamic>> call(String function, Map<String, dynamic> body);
}

class AppAmbitCloudService implements CloudService {
  const AppAmbitCloudService();

  static const _networkCodes = {
    CloudCodeErrorCode.networkUnavailable,
    CloudCodeErrorCode.timedOut,
    CloudCodeErrorCode.transport,
    CloudCodeErrorCode.http,
  };

  @override
  Future<Map<String, dynamic>> call(String function, Map<String, dynamic> body) async {
    final CloudCodeResponse response;
    try {
      response = await CloudCode.call(function, body: body, timeout: const Duration(seconds: 20)).future;
    } on CloudCodeError catch (e) {
      throw AppFailure(_networkCodes.contains(e.code) ? FailureKind.noConnection : FailureKind.unexpected, e);
    } catch (e) {
      throw AppFailure(FailureKind.noConnection, e);
    }
    final data = response.data is String ? jsonDecode(response.data! as String) : response.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw AppFailure(FailureKind.unexpected, 'Unexpected response from $function');
  }
}
