import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/features/hr/domain/entities/employee_entity.dart';
import 'package:live_technical/features/hr/presentation/widgets/employee_card.dart';

void main() {
  const employee = EmployeeEntity(
    id: '1',
    firstName: 'Amro',
    middleName: 'Ali',
    lastName: 'Handousa',
    jobTitle: 'Marketing Manger',
    department: 'Marketing',
  );

  Widget buildCard({VoidCallback? onMessagePressed}) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: EmployeeCard(
          employee: employee,
          onMessagePressed: onMessagePressed,
        ),
      ),
    ),
  );

  testWidgets('shows full name, job title, department and message button', (
    tester,
  ) async {
    await tester.pumpWidget(buildCard());

    expect(find.text('Amro Ali Handousa'), findsOneWidget);
    expect(find.text('Marketing Manger'), findsOneWidget);
    expect(find.text('Marketing'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('invokes callback when Message is tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(buildCard(onMessagePressed: () => tapped = true));

    await tester.tap(find.text('Message'));
    expect(tapped, isTrue);
  });
}
