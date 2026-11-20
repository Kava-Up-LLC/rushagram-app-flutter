import 'core/appambit/analytics.dart';
import 'core/appambit/cloud_service.dart';
import 'core/appambit/diagnostics.dart';
import 'core/appambit/push_service.dart';
import 'core/local_store.dart';
import 'features/daily/data/daily_repository.dart';

/// Everything the screens need, built once in main.dart and passed down by constructor.
class AppServices {
  AppServices({
    required this.cloud,
    required this.analytics,
    required this.push,
    required this.diagnostics,
    required this.store,
    required this.platform,
    required this.share,
    DailyRepository? daily,
  }) : daily = daily ?? CloudDailyRepository(cloud: cloud, store: store, platform: platform);

  final CloudService cloud;
  final Analytics analytics;
  final PushService push;
  final Diagnostics diagnostics;
  final LocalStore store;
  final String platform;
  final DailyRepository daily;

  /// System share sheet (share_plus in the app, a fake in tests).
  final Future<void> Function(String text) share;
}
