import 'package:appambit_sdk_flutter/appambit_sdk_flutter.dart';

/// Usage events in AppAmbit Analytics (spec §8). No personal data: never a nickname.
abstract interface class Analytics {
  void track(String event, [Map<String, String> properties]);
}

class AppAmbitAnalytics implements Analytics {
  const AppAmbitAnalytics();

  @override
  void track(String event, [Map<String, String> properties = const {}]) {
    AppAmbitSdk.trackEvent(event, properties).catchError((_) {});
  }
}
