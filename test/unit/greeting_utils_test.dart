import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/greeting_utils.dart';

void main() {
  group('getGreeting()', () {
    DateTime t(int h, [int m = 0]) => DateTime(2024, 6, 1, h, m);

    test('08:00 -> Good morning,', () => expect(getGreeting(t(8)), 'Good morning,'));
    test('05:00 boundary -> Good morning,', () => expect(getGreeting(t(5, 0)), 'Good morning,'));
    test('11:59 boundary -> Good morning,', () => expect(getGreeting(t(11, 59)), 'Good morning,'));

    test('12:00 boundary -> Good afternoon,', () => expect(getGreeting(t(12, 0)), 'Good afternoon,'));
    test('14:30 -> Good afternoon,', () => expect(getGreeting(t(14, 30)), 'Good afternoon,'));
    test('16:59 boundary -> Good afternoon,', () => expect(getGreeting(t(16, 59)), 'Good afternoon,'));

    test('17:00 boundary -> Good evening,', () => expect(getGreeting(t(17, 0)), 'Good evening,'));
    test('19:00 -> Good evening,', () => expect(getGreeting(t(19, 0)), 'Good evening,'));
    test('20:59 boundary -> Good evening,', () => expect(getGreeting(t(20, 59)), 'Good evening,'));

    test('21:00 boundary -> Good night,', () => expect(getGreeting(t(21, 0)), 'Good night,'));
    test('23:59 -> Good night,', () => expect(getGreeting(t(23, 59)), 'Good night,'));
    test('00:00 midnight -> Good night,', () => expect(getGreeting(t(0, 0)), 'Good night,'));
    test('04:59 boundary -> Good night,', () => expect(getGreeting(t(4, 59)), 'Good night,'));

    test('returns 4 distinct greeting values', () {
      final greetings = {
        getGreeting(t(8)),
        getGreeting(t(13)),
        getGreeting(t(18)),
        getGreeting(t(22)),
      };
      expect(greetings, {
        'Good morning,',
        'Good afternoon,',
        'Good evening,',
        'Good night,',
      });
    });
  });
}
