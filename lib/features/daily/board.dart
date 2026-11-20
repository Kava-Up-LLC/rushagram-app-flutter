import 'dart:math';

/// The game rules, plain Dart (no Flutter): six tiles, six slots.
///
/// [order] is where each tile sits on screen (Shuffle changes it); [slots] holds, for each answer slot,
/// the index of the letter placed there. A letter in a slot leaves its tile empty.
class Board {
  Board(String letters)
      : letters = letters.toUpperCase().split(''),
        order = List.generate(letters.length, (i) => i),
        slots = List.filled(letters.length, null);

  Board._(this.letters, this.order, this.slots);

  final List<String> letters;
  final List<int> order;
  final List<int?> slots;

  int get size => letters.length;
  bool isUsed(int letter) => slots.contains(letter);
  bool get isFull => slots.every((s) => s != null);
  bool get isEmpty => slots.every((s) => s == null);
  String get guess => slots.map((s) => s == null ? '' : letters[s]).join();

  /// Tap a tile: its letter goes to the first free slot.
  Board tap(int letter) {
    if (isUsed(letter) || isFull) return this;
    final next = List<int?>.of(slots);
    next[next.indexOf(null)] = letter;
    return Board._(letters, order, next);
  }

  /// Tap a filled slot: its letter goes back to its tile.
  Board untap(int slot) {
    if (slots[slot] == null) return this;
    final next = List<int?>.of(slots)..[slot] = null;
    return Board._(letters, order, next);
  }

  Board clear() => Board._(letters, order, List.filled(size, null));

  /// New tile positions, never the same order as before (when there is more than one way).
  Board shuffle([int Function(int max)? random]) {
    final pick = random ?? Random().nextInt;
    final next = List<int>.of(order);
    for (var tries = 0; tries < 10; tries++) {
      for (var i = next.length - 1; i > 0; i--) {
        final j = pick(i + 1);
        final t = next[i];
        next[i] = next[j];
        next[j] = t;
      }
      if (!_same(next, order)) break;
    }
    return Board._(letters, next, slots);
  }

  static bool _same(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
