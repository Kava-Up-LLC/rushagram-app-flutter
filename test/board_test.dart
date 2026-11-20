import 'package:flutter_test/flutter_test.dart';
import 'package:rushagram_app/features/daily/board.dart';

void main() {
  test('tap fills the next slot, a used tile does nothing', () {
    var b = Board('motato');
    expect(b.letters, ['M', 'O', 'T', 'A', 'T', 'O']);
    b = b.tap(2).tap(1);
    expect(b.guess, 'TO');
    expect(b.isUsed(2), isTrue);
    expect(b.tap(2).guess, 'TO');
  });

  test('untap sends a letter back; the next tap fills that hole first', () {
    var b = Board('MOTATO').tap(2).tap(1).tap(0);
    b = b.untap(1);
    expect(b.slots, [2, null, 0, null, null, null]);
    expect(b.isUsed(1), isFalse);
    b = b.tap(5);
    expect(b.guess, 'TOM');
    expect(b.untap(4), same(b));
  });

  test('full board makes the guess; clear empties everything', () {
    var b = Board('MOTATO');
    for (final i in [2, 1, 0, 3, 4, 5]) {
      b = b.tap(i);
    }
    expect(b.isFull, isTrue);
    expect(b.guess, 'TOMATO');
    expect(b.tap(0), same(b));
    b = b.clear();
    expect(b.isEmpty, isTrue);
  });

  test('shuffle changes where tiles sit, never the letters or the slots', () {
    final b = Board('MOTATO').tap(0);
    var n = 0;
    final s = b.shuffle((max) => (n++ * 5) % max);
    expect(s.order, isNot(b.order));
    expect([...s.order]..sort(), [0, 1, 2, 3, 4, 5]);
    expect(s.slots, b.slots);
    expect(s.letters, b.letters);
  });
}
