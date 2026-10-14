import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/common/custom_exception.dart';
import 'package:live_technical/core/di/di.dart';
import 'package:live_technical/core/resources/app_constants.dart';
import 'package:live_technical/core/utils/validators.dart';
import 'package:live_technical/core/widgets/confirmation_dialog.dart';
import 'package:live_technical/core/widgets/success_dialog.dart';
import 'package:live_technical/features/hr/presentation/views/add_employee_view.dart';

import '../../test_support.dart';

void main() {
  late FakeEmployeeRepo repo;
  bool? popResult;

  setUp(() {
    repo = FakeEmployeeRepo();
    popResult = null;
    registerHrDependencies(repo);
  });

  tearDown(() async => getIt.reset());

  Future<void> pumpScreen(
    WidgetTester tester, {
    Size size = const Size(1200, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  popResult = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const AddEmployeeView()),
                  );
                },
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  Future<void> fillForm(WidgetTester tester) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Amro');
    await tester.enterText(fields.at(1), 'M');
    await tester.enterText(fields.at(2), 'Handousa');
    await tester.enterText(fields.at(3), 'Manager');
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marketing').last);
    await tester.pumpAndSettle();
  }

  Future<void> tapSubmit(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('Submit'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders breadcrumb, picker, fields and buttons', (tester) async {
    await pumpScreen(tester);

    expect(find.text('HR'), findsOneWidget);
    expect(find.text('Employees'), findsOneWidget);
    expect(find.text('Adding New Employee'), findsOneWidget);
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    for (final label in [
      'First Name',
      'Middle Name',
      'Last Name',
      'Department',
      'Job Title',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Discard'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty submit shows required errors and no dialog', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tapSubmit(tester);

    // first name, last name, department, job title (middle name is optional)
    expect(find.text(Validators.requiredMessage), findsNWidgets(4));
    expect(find.byType(ConfirmationDialog), findsNothing);
    expect(repo.addCalls, 0);
  });

  testWidgets('Discard goes back without saving', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(find.byType(AddEmployeeView), findsNothing);
    expect(popResult, isNull);
    expect(repo.addCalls, 0);
  });

  testWidgets('choosing No in the confirmation does not save', (tester) async {
    await pumpScreen(tester);
    await fillForm(tester);

    await tapSubmit(tester);
    expect(find.text('Creating Employee'), findsOneWidget);

    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    expect(find.byType(ConfirmationDialog), findsNothing);
    expect(find.byType(AddEmployeeView), findsOneWidget);
    expect(repo.addCalls, 0);
  });

  testWidgets('Yes saves, shows loading, success dialog, then pops true', (
    tester,
  ) async {
    repo.addGate = Completer<void>();
    await pumpScreen(tester);
    await fillForm(tester);

    await tapSubmit(tester);
    await tester.tap(find.text('Yes'));
    await tester.pump();

    expect(repo.addCalls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repo.addGate!.complete();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(SuccessDialog), findsOneWidget);
    expect(find.text('You Successfully Created Employee'), findsOneWidget);

    await tester.pump(AppConstants.successDialogDuration);
    await tester.pumpAndSettle();

    expect(find.byType(AddEmployeeView), findsNothing);
    expect(popResult, true);
    final saved = repo.employees.single;
    expect(saved.firstName, 'Amro');
    expect(saved.middleName, 'M');
    expect(saved.lastName, 'Handousa');
    expect(saved.department, 'Marketing');
    expect(saved.jobTitle, 'Manager');
  });

  testWidgets('failure keeps the screen and shows the error', (tester) async {
    repo.addError = FirestoreError('permission-denied');
    await pumpScreen(tester);
    await fillForm(tester);

    await tapSubmit(tester);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(find.text('permission-denied'), findsOneWidget);
    expect(find.byType(AddEmployeeView), findsOneWidget);
    expect(find.byType(SuccessDialog), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  group('responsive form', () {
    double top(WidgetTester tester, String label) =>
        tester.getTopLeft(find.text(label)).dy;

    testWidgets('3 columns on a wide screen', (tester) async {
      await pumpScreen(tester, size: const Size(1200, 900));

      expect(top(tester, 'First Name'), top(tester, 'Middle Name'));
      expect(top(tester, 'Middle Name'), top(tester, 'Last Name'));
      expect(top(tester, 'Department') > top(tester, 'First Name'), isTrue);
    });

    testWidgets('2 columns on a medium screen', (tester) async {
      await pumpScreen(tester, size: const Size(700, 900));

      expect(top(tester, 'First Name'), top(tester, 'Middle Name'));
      expect(top(tester, 'Last Name') > top(tester, 'First Name'), isTrue);
    });

    testWidgets('1 column on a phone without overflow', (tester) async {
      await pumpScreen(tester, size: const Size(360, 640));

      expect(top(tester, 'Middle Name') > top(tester, 'First Name'), isTrue);
      expect(tester.takeException(), isNull);

      await tapSubmit(tester);
      expect(tester.takeException(), isNull);
    });
  });
}
