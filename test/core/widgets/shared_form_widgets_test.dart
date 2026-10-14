import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/di/di.dart';
import 'package:live_technical/core/widgets/app_date_form_field.dart';
import 'package:live_technical/core/widgets/app_dropdown_form_field.dart';
import 'package:live_technical/core/widgets/app_text_form_field.dart';
import 'package:live_technical/core/widgets/bilingual_info_fields.dart';
import 'package:live_technical/core/widgets/error_snack_bar.dart';
import 'package:live_technical/core/widgets/loading_overlay.dart';
import 'package:live_technical/core/widgets/profile_image_picker.dart';
import 'package:live_technical/features/database_builder/domain/entities/database_enums.dart';
import 'package:live_technical/features/database_builder/presentation/widgets/database_options.dart';
import 'package:live_technical/features/hr/presentation/widgets/employee_picker_filters.dart';
import 'package:live_technical/features/hr/presentation/widgets/selectable_employee_card.dart';
import 'package:live_technical/features/hr/presentation/widgets/selected_employee_avatars.dart';

import '../../features/database_builder/test_support.dart';
import '../theme/theme_test_support.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  setUp(() async => registerThemeDependencies());
  tearDown(() async => getIt.reset());

  group('AppTextFormField', () {
    testWidgets('reports every change', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        host(
          AppTextFormField(
            label: 'Name',
            controller: TextEditingController(),
            onChanged: changes.add,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'abc');

      expect(changes, ['abc']);
    });
  });

  group('AppDropdownFormField', () {
    testWidgets('shows the given value and hint otherwise', (tester) async {
      await tester.pumpWidget(
        host(
          AppDropdownFormField(
            label: 'Access',
            items: const ['A', 'B'],
            value: 'B',
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text('B'), findsOneWidget);
      expect(find.text('Select'), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        host(
          AppDropdownFormField(
            label: 'Access',
            items: const ['A', 'B'],
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text('Select'), findsOneWidget);
    });
  });

  group('AppDateFormField', () {
    testWidgets('shows the hint, then the picked date, and reports it', (
      tester,
    ) async {
      final picked = <DateTime>[];
      await tester.pumpWidget(
        host(AppDateFormField(label: 'Start Date', onChanged: picked.add)),
      );
      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('Select Date'), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(picked.single.day, 15);
      expect(find.text('Select Date'), findsNothing);
      expect(find.textContaining('15 '), findsOneWidget);
    });

    testWidgets('cancelling keeps the value', (tester) async {
      final picked = <DateTime>[];
      await tester.pumpWidget(
        host(AppDateFormField(label: 'Start Date', onChanged: picked.add)),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(picked, isEmpty);
      expect(find.text('Select Date'), findsOneWidget);
    });

    testWidgets('shows the initial value and the validator error', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        host(
          Form(
            key: formKey,
            child: Column(
              children: [
                AppDateFormField(
                  label: 'Start Date',
                  initialValue: DateTime(2024, 3, 9),
                  onChanged: (_) {},
                ),
                AppDateFormField(
                  label: 'End Date',
                  onChanged: (_) {},
                  validator: (v) => v == null ? 'needed' : null,
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('9 Mar 2024'), findsOneWidget);

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();

      expect(find.text('needed'), findsOneWidget);
    });
  });

  group('BilingualInfoFields', () {
    testWidgets('renders the 4 fields with their labels', (tester) async {
      await tester.pumpWidget(
        host(
          BilingualInfoFields(
            titleLabel: 'Title',
            titleArLabel: 'عنوان',
            titleController: TextEditingController(),
            titleArController: TextEditingController(),
            descriptionController: TextEditingController(),
            descriptionArController: TextEditingController(),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsNWidgets(4));
      for (final label in ['Title', 'عنوان', 'Description', 'وصف']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('forwards each callback and validator', (tester) async {
      final calls = <String>[];
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        host(
          Form(
            key: formKey,
            child: BilingualInfoFields(
              titleLabel: 'Title',
              titleArLabel: 'عنوان',
              titleController: TextEditingController(),
              titleArController: TextEditingController(),
              descriptionController: TextEditingController(),
              descriptionArController: TextEditingController(),
              titleValidator: (v) => v!.isEmpty ? 'title!' : null,
              descriptionValidator: (v) => v!.isEmpty ? 'desc!' : null,
              onTitleChanged: (v) => calls.add('t:$v'),
              onTitleArChanged: (v) => calls.add('ta:$v'),
              onDescriptionChanged: (v) => calls.add('d:$v'),
              onDescriptionArChanged: (v) => calls.add('da:$v'),
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('title!'), findsOneWidget);
      expect(find.text('desc!'), findsOneWidget);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '1');
      await tester.enterText(fields.at(1), '2');
      await tester.enterText(fields.at(2), '3');
      await tester.enterText(fields.at(3), '4');
      expect(calls, ['t:1', 'ta:2', 'd:3', 'da:4']);
    });
  });

  group('ProfileImagePicker', () {
    testWidgets('uses the given semantics label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const ProfileImagePicker(semanticLabel: 'Choose database image')),
      );

      expect(find.bySemanticsLabel('Choose database image'), findsOneWidget);
      handle.dispose();
    });
  });

  group('SelectedEmployeeAvatars', () {
    testWidgets('has no remove badges without onRemove', (tester) async {
      await tester.pumpWidget(
        host(SelectedEmployeeAvatars(employees: wizardEmployees())),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('removes the tapped employee by id', (tester) async {
      final removed = <String>[];
      await tester.pumpWidget(
        host(
          SelectedEmployeeAvatars(
            employees: wizardEmployees().take(2).toList(),
            onRemove: removed.add,
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNWidgets(2));
      await tester.tap(find.byIcon(Icons.close).last);

      expect(removed, ['e2']);
    });
  });

  group('SelectableEmployeeCard', () {
    testWidgets('checkbox uses the given active color', (tester) async {
      await tester.pumpWidget(
        host(
          SizedBox(
            height: 120,
            child: SelectableEmployeeCard(
              employee: wizardEmployees().first,
              selected: true,
              onChanged: () {},
              activeColor: Colors.purple,
            ),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.activeColor, Colors.purple);
    });
  });

  group('EmployeePickerFilters', () {
    testWidgets('uses a custom "all" label and reports null for it', (
      tester,
    ) async {
      String? picked = 'unset';
      await tester.pumpWidget(
        host(
          EmployeePickerFilters(
            departments: const ['HR'],
            selectedDepartment: 'HR',
            allLabel: 'Everyone',
            onSearchChanged: (_) {},
            onDepartmentChanged: (value) => picked = value,
          ),
        ),
      );

      await tester.tap(find.text('HR'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Everyone').last);
      await tester.pumpAndSettle();

      expect(picked, isNull);
    });
  });

  group('LoadingOverlay and error snack bar', () {
    testWidgets('overlay shows a spinner over the content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [Text('below'), LoadingOverlay()]),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('showErrorSnackBar displays the message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showErrorSnackBar(context, 'Oops'),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pump();

      expect(find.text('Oops'), findsOneWidget);
    });
  });

  group('DatabaseOptions', () {
    test('lists the access labels in enum order', () {
      expect(DatabaseOptions.accessLabels, [
        'Open Access',
        'Restricted Access',
        'Personal Access',
      ]);
    });

    test('lists and maps the permissions', () {
      expect(DatabaseOptions.permissionLabels, [
        'Full Access',
        'Edit',
        'Export',
        'View',
      ]);
      for (final permission in DatabasePermission.values) {
        expect(
          DatabaseOptions.permissionFromLabel(permission.label),
          permission,
        );
      }
      expect(DatabaseOptions.permissionFromLabel('nope'), isNull);
    });

    test('maps labels back to access types', () {
      for (final type in AccessType.values) {
        expect(DatabaseOptions.accessTypeFromLabel(type.label), type);
      }
      expect(DatabaseOptions.accessTypeFromLabel(null), isNull);
      expect(DatabaseOptions.accessTypeFromLabel('nope'), isNull);
    });
  });
}
