import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/resources/app_constants.dart';
import 'package:live_technical/core/widgets/confirmation_dialog.dart';
import 'package:live_technical/core/widgets/success_dialog.dart';
import 'package:live_technical/core/widgets/warning_dialog.dart';

void main() {
  Future<void> openDialog(
    WidgetTester tester,
    WidgetBuilder builder,
    ValueChanged<Object?> onResult,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async => onResult(
                  await showDialog<Object?>(context: context, builder: builder),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('ConfirmationDialog', () {
    Widget dialog(BuildContext _) => const ConfirmationDialog(
      title: 'Creating Employee',
      message: 'Are you sure?',
    );

    testWidgets('shows title, message and both buttons', (tester) async {
      await openDialog(tester, dialog, (_) {});

      expect(find.text('Creating Employee'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('Yes returns true', (tester) async {
      Object? result;
      await openDialog(tester, dialog, (r) => result = r);

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(result, true);
      expect(find.byType(ConfirmationDialog), findsNothing);
    });

    testWidgets('No returns false', (tester) async {
      Object? result;
      await openDialog(tester, dialog, (r) => result = r);

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(result, false);
    });
  });

  group('WarningDialog', () {
    testWidgets('shows the warning and closes on outside tap', (tester) async {
      var closed = false;
      await openDialog(
        tester,
        (_) => const WarningDialog(
          message:
              'Marketing Already Exist As A Board Please Choose A Different Name',
        ),
        (_) => closed = true,
      );

      expect(find.text('Warning'), findsOneWidget);
      expect(
        find.text(
          'Marketing Already Exist As A Board Please Choose A Different Name',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.error), findsOneWidget);

      await tester.tapAt(const Offset(2, 2));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      expect(find.byType(WarningDialog), findsNothing);
    });
  });

  group('SuccessDialog', () {
    testWidgets('shows the message and closes itself', (tester) async {
      var closed = false;
      await openDialog(
        tester,
        (_) => const SuccessDialog(
          title: 'Successful',
          message: 'You Successfully Created Employee',
        ),
        (_) => closed = true,
      );

      expect(find.text('Successful'), findsOneWidget);
      expect(find.text('You Successfully Created Employee'), findsOneWidget);
      expect(closed, isFalse);

      await tester.pump(AppConstants.successDialogDuration);
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      expect(find.byType(SuccessDialog), findsNothing);
    });
  });
}
