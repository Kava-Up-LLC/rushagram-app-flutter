import 'package:appambit_sdk_push_notifications/appambit_sdk_push_notifications.dart';

/// AppAmbit push. The cloud sends "Today's Rushagram is ready." every morning (morning_push);
/// the app registers, asks once, and opens today's puzzle when a notification is tapped.
abstract interface class PushService {
  Future<void> start();
  Future<bool> requestPermission();
  void onOpened(void Function(Map<String, String> data) handler);
}

class AppAmbitPushService implements PushService {
  const AppAmbitPushService();

  @override
  Future<void> start() async {
    try {
      await PushNotificationsSdk.start();
      // Android boots push with delivery off; turn it on whenever permission is granted (safe to repeat).
      if (await PushNotificationsSdk.hasNotificationPermission()) {
        await PushNotificationsSdk.setNotificationsEnabled(true);
      }
    } catch (_) {
      // No push credentials on this build: the game still works, it just won't get the morning nudge.
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      await PushNotificationsSdk.requestNotificationPermission();
      final granted = await PushNotificationsSdk.hasNotificationPermission();
      if (granted) await PushNotificationsSdk.setNotificationsEnabled(true);
      return granted;
    } catch (_) {
      return false;
    }
  }

  @override
  void onOpened(void Function(Map<String, String> data) handler) {
    PushNotificationsSdk.setOpenedListener((p) => handler(p.data ?? const {}));
  }
}
