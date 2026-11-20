import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// The only things kept on the phone: who this player is, their nickname, and whether we already asked for
/// notifications. Everything else lives in AppAmbit.
abstract interface class LocalStore {
  String get playerId;
  String? get nickname;
  Future<void> saveNickname(String nickname);
  bool get pushAsked;
  Future<void> markPushAsked();
}

class PrefsStore implements LocalStore {
  PrefsStore._(this._prefs, this.playerId);

  static Future<PrefsStore> open() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('player_id');
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString('player_id', id);
    }
    return PrefsStore._(prefs, id);
  }

  final SharedPreferences _prefs;
  @override
  final String playerId;

  @override
  String? get nickname => _prefs.getString('nickname');
  @override
  Future<void> saveNickname(String nickname) => _prefs.setString('nickname', nickname.trim());
  @override
  bool get pushAsked => _prefs.getBool('push_asked') ?? false;
  @override
  Future<void> markPushAsked() => _prefs.setBool('push_asked', true);
}
