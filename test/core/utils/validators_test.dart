import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/utils/validators.dart';

void main() {
  group('requiredMaxLength', () {
    test('rejects empty and blank text', () {
      expect(Validators.requiredMaxLength(null, 5), Validators.requiredMessage);
      expect(
        Validators.requiredMaxLength('   ', 5),
        Validators.requiredMessage,
      );
    });

    test('accepts text up to the limit', () {
      expect(Validators.requiredMaxLength('abcde', 5), isNull);
    });

    test('rejects text over the limit', () {
      expect(Validators.requiredMaxLength('abcdef', 5), 'Maximum 5 Characters');
    });
  });

  group('endDateAfterStart', () {
    final start = DateTime(2024, 3, 1);

    test('requires an end date', () {
      expect(
        Validators.endDateAfterStart(null, start),
        Validators.requiredMessage,
      );
    });

    test('accepts an end date after the start', () {
      expect(Validators.endDateAfterStart(DateTime(2024, 3, 2), start), isNull);
    });

    test('rejects the same day', () {
      expect(
        Validators.endDateAfterStart(start, start),
        Validators.endBeforeStartMessage,
      );
    });

    test('rejects an end date before the start', () {
      expect(
        Validators.endDateAfterStart(DateTime(2024, 2, 1), start),
        Validators.endBeforeStartMessage,
      );
    });

    test('without a start date any end date is fine', () {
      expect(Validators.endDateAfterStart(DateTime(2024, 2, 1), null), isNull);
    });
  });
}
