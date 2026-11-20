import 'package:flutter_test/flutter_test.dart';
import 'package:rushagram_app/core/format.dart';

void main() {
  test('time', () {
    expect(formatTime(23000), '0:23');
    expect(formatTime(83400), '1:23');
    expect(formatTime(0), '0:00');
  });

  test('countdown', () {
    expect(formatCountdown(const Duration(hours: 5, minutes: 12, seconds: 40)), '5h 12m');
    expect(formatCountdown(const Duration(minutes: 7)), '7m');
    expect(formatCountdown(const Duration(seconds: 20)), 'less than a minute');
  });

  test('share text', () => expect(formatShare(number: 12, timeMs: 23400, rank: 14), 'Rushagram #12 · 0:23 · #14 today'));

  test('nickname', () {
    expect(isValidNickname('Ana'), isTrue);
    expect(isValidNickname(' Leo 2 '), isTrue);
    expect(isValidNickname('A'), isFalse);
    expect(isValidNickname('Ana!'), isFalse);
    expect(isValidNickname('x' * 17), isFalse);
  });
}
