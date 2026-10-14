import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/utils/date_formatter.dart';

void main() {
  test('formats day, short month and year', () {
    expect(formatDate(DateTime(2023, 12, 28)), '28 Dec 2023');
    expect(formatDate(DateTime(2024, 1, 5)), '5 Jan 2024');
  });

  test('every month has its short name', () {
    const expected = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    for (var month = 1; month <= 12; month++) {
      expect(
        formatDate(DateTime(2024, month, 1)),
        '1 ${expected[month - 1]} 2024',
      );
    }
  });

  test('a missing date shows a dash', () {
    expect(formatDate(null), '-');
  });
}
