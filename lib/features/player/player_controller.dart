import 'package:flutter/foundation.dart';

import '../../core/appambit/analytics.dart';
import '../../core/format.dart';
import '../../core/local_store.dart';

/// F1 — the nickname. No account: the phone keeps a player id and the nickname.
class PlayerController extends ChangeNotifier {
  PlayerController({required this.store, required this.analytics});

  final LocalStore store;
  final Analytics analytics;

  String? error;

  /// Returns true when saved.
  Future<bool> save(String nickname) async {
    if (!isValidNickname(nickname)) {
      error = 'Use 2 to 16 letters or numbers.';
      notifyListeners();
      return false;
    }
    error = null;
    await store.saveNickname(nickname);
    analytics.track('nickname_set');
    notifyListeners();
    return true;
  }
}
