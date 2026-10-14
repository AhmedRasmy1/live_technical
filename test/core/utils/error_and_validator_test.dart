import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/common/custom_exception.dart';
import 'package:live_technical/core/utils/extract_error_message.dart';
import 'package:live_technical/core/utils/validators.dart';

void main() {
  group('Validators.requiredField', () {
    test('rejects null, empty and blank values', () {
      expect(Validators.requiredField(null), Validators.requiredMessage);
      expect(Validators.requiredField(''), Validators.requiredMessage);
      expect(Validators.requiredField('   '), Validators.requiredMessage);
    });

    test('accepts a real value', () {
      expect(Validators.requiredField('Amro'), isNull);
    });
  });

  group('extractErrorMessage', () {
    test('handles each exception type', () {
      expect(
        extractErrorMessage(NoInternetError()),
        'please check internet connection',
      );
      expect(extractErrorMessage(FirestoreError('denied')), 'denied');
      expect(extractErrorMessage(FirestoreError(null)), 'something went wrong');
      expect(extractErrorMessage(ServerError(serverMessage: 'boom')), 'boom');
      expect(extractErrorMessage(FirebaseAuthError('bad')), 'bad');
      expect(extractErrorMessage(null), 'something went wrong');
      expect(extractErrorMessage(Exception('x')), 'something went wrong');
    });
  });
}
