import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/features/hr/presentation/views/employee_view.dart';
import 'package:live_technical/features/hr/presentation/widgets/employee_card.dart';
import 'package:live_technical/features/hr/presentation/widgets/employee_header.dart';

void main() {
  Future<void> pumpView(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: EmployeeView()));
    await tester.pumpAndSettle();
  }

  testWidgets('renders header, search, buttons and employee cards', (
    tester,
  ) async {
    await pumpView(tester, const Size(1200, 900));

    expect(
      find.descendant(
        of: find.byType(EmployeeHeader),
        matching: find.text('HR'),
      ),
      findsOneWidget,
    );
    expect(find.text('Employee'), findsNWidgets(2)); // breadcrumb + button
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Filter'), findsOneWidget);
    expect(find.byType(EmployeeCard), findsWidgets);
    expect(tester.takeException(), isNull);
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
}
