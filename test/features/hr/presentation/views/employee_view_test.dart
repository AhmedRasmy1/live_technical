import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/common/custom_exception.dart';
import 'package:live_technical/core/di/di.dart';
import 'package:live_technical/core/resources/app_constants.dart';
import 'package:live_technical/core/widgets/breadcrumb_header.dart';
import 'package:live_technical/features/hr/presentation/views/add_employee_view.dart';
import 'package:live_technical/features/hr/presentation/views/employee_view.dart';
import 'package:live_technical/features/hr/presentation/widgets/employee_card.dart';

import '../../test_support.dart';

void main() {
  late FakeEmployeeRepo repo;

  setUp(() {
    repo = FakeEmployeeRepo(employees: sampleEmployees(12));
    registerHrDependencies(repo);
  });

  tearDown(() async => getIt.reset());

  Future<void> pumpView(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: EmployeeView()));
    await tester.pumpAndSettle();
  }

  testWidgets('renders header, search, buttons and fetched employees', (
    tester,
  ) async {
    await pumpView(tester, const Size(1200, 900));

    expect(
      find.descendant(
        of: find.byType(BreadcrumbHeader),
        matching: find.text('HR'),
      ),
      findsOneWidget,
    );
    expect(find.text('Employee'), findsNWidgets(2)); // breadcrumb + button
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Filter'), findsOneWidget);
    expect(repo.getCalls, 1);
    expect(find.byType(EmployeeCard), findsWidgets);
    expect(find.text('First0 Mid0 Last0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a loader while fetching', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: EmployeeView()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows an empty message when there are no employees', (
    tester,
  ) async {
    repo.employees.clear();
    await pumpView(tester, const Size(1200, 900));

    expect(find.text('No employees yet'), findsOneWidget);
    expect(find.byType(EmployeeCard), findsNothing);
  });

  testWidgets('shows the error with Retry that fetches again', (tester) async {
    repo.getError = FirestoreError('unavailable');
    await pumpView(tester, const Size(1200, 900));

    expect(find.text('unavailable'), findsOneWidget);

    repo.getError = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(repo.getCalls, 2);
    expect(find.byType(EmployeeCard), findsWidgets);
  });

  testWidgets('grid adapts column count to screen width', (tester) async {
    Future<int> columnsAt(Size size) async {
      await pumpView(tester, size);
      final firstRowTop = tester.getTopLeft(find.byType(EmployeeCard).first).dy;
      return find
          .byType(EmployeeCard)
          .evaluate()
          .map((e) => tester.getTopLeft(find.byWidget(e.widget)).dy)
          .where((dy) => dy == firstRowTop)
          .length;
    }

    expect(await columnsAt(const Size(360, 800)), 1);
    expect(await columnsAt(const Size(800, 900)), 2);
    expect(await columnsAt(const Size(1200, 900)), 3);
  });

  testWidgets('opens and closes filter panel', (tester) async {
    await pumpView(tester, const Size(1200, 900));

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();

    expect(find.text('Job Title'), findsOneWidget);
    expect(find.text('Department'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('Apply'), findsNothing);
  });

  testWidgets('does not overflow on a small phone screen', (tester) async {
    await pumpView(tester, const Size(320, 600));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();
    expect(find.text('Apply'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adding an employee refreshes the list with the new one', (
    tester,
  ) async {
    await pumpView(tester, const Size(1200, 900));
    expect(find.text('Nada Said Hassan'), findsNothing);

    await tester.tap(find.byIcon(Icons.badge_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(AddEmployeeView), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Nada');
    await tester.enterText(fields.at(1), 'Said');
    await tester.enterText(fields.at(2), 'Hassan');
    await tester.enterText(fields.at(3), 'Designer');
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Design').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.pump(AppConstants.successDialogDuration);
    await tester.pumpAndSettle();

    expect(find.byType(AddEmployeeView), findsNothing);
    expect(repo.getCalls, 2);
    expect(find.text('Nada Said Hassan'), findsOneWidget);
  });
}
