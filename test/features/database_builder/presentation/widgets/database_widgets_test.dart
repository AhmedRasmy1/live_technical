import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/resources/app_constants.dart';
import 'package:live_technical/core/resources/color_manager.dart';
import 'package:live_technical/core/theme/app_colors.dart';
import 'package:live_technical/core/theme/theme_manager.dart';
import 'package:live_technical/features/database_builder/domain/entities/database_entity.dart';
import 'package:live_technical/features/database_builder/domain/entities/database_enums.dart';
import 'package:live_technical/features/database_builder/presentation/viewmodels/database_list_cubit/database_list_cubit.dart';
import 'package:live_technical/features/database_builder/presentation/widgets/database_card.dart';
import 'package:live_technical/features/database_builder/presentation/widgets/database_filter_panel.dart';
import 'package:live_technical/features/database_builder/presentation/widgets/database_tabs_bar.dart';
import 'package:live_technical/features/database_builder/presentation/widgets/sort_menu_button.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(800, 600),
  ThemeData? theme,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

DatabaseEntity _database({
  String title = 'Lorem Ipsum',
  int tables = 15,
  AccessType access = AccessType.open,
  DatabaseStatus status = DatabaseStatus.open,
  DateTime? created,
  DateTime? edited,
  DateTime? deleted,
}) => DatabaseEntity(
  title: title,
  tablesCount: tables,
  accessType: access,
  status: status,
  creationDate: created ?? DateTime(2023, 12, 28),
  lastEditDate: edited ?? DateTime(2024, 1, 5),
  deletedDate: deleted,
);

void main() {
  group('DatabaseCard', () {
    Future<void> pumpCard(
      WidgetTester tester,
      DatabaseEntity database, {
      VoidCallback? onMenu,
    }) => _pump(
      tester,
      SizedBox(
        width: 320,
        height: AppConstants.databaseCardHeight,
        child: DatabaseCard(database: database, onMenuPressed: onMenu),
      ),
    );

    testWidgets('shows title, tables, creation, last edit and access', (
      tester,
    ) async {
      await pumpCard(tester, _database());

      expect(find.text('Lorem Ipsum'), findsOneWidget);
      expect(
        find.textContaining('No. Of Tables: 15', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Creation: 28 Dec 2023', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Last Edit: 5 Jan 2024', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Access: Open Access', findRichText: true),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.storage_outlined), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    testWidgets('a deleted database shows the deleted date instead', (
      tester,
    ) async {
      await pumpCard(
        tester,
        _database(
          status: DatabaseStatus.deleted,
          deleted: DateTime(2024, 2, 3),
        ),
      );

      expect(
        find.textContaining('Deleted: 3 Feb 2024', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Last Edit', findRichText: true),
        findsNothing,
      );
    });

    testWidgets('no tables shows a dash', (tester) async {
      await pumpCard(tester, _database(tables: 0));

      expect(
        find.textContaining('No. Of Tables: -', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('shows each access type label', (tester) async {
      for (final type in AccessType.values) {
        await pumpCard(tester, _database(access: type));
        expect(
          find.textContaining('Access: ${type.label}', findRichText: true),
          findsOneWidget,
        );
      }
    });

    testWidgets('a very long title is ellipsized without overflow', (
      tester,
    ) async {
      await pumpCard(
        tester,
        _database(title: 'A very long database title ' * 5),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('the menu button calls back when given', (tester) async {
      var taps = 0;
      await pumpCard(tester, _database(), onMenu: () => taps++);

      await tester.tap(find.byIcon(Icons.more_horiz));

      expect(taps, 1);
    });

    testWidgets('uses the dark surface in dark mode', (tester) async {
      await _pump(
        tester,
        SizedBox(
          width: 320,
          height: AppConstants.databaseCardHeight,
          child: DatabaseCard(database: _database()),
        ),
        theme: ThemeManager.dark,
      );

      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(DatabaseCard),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((card.decoration as BoxDecoration).color, AppColors.dark.surface);
    });
  });

  group('DatabaseTabsBar', () {
    final counts = {
      DatabaseTab.all: 14,
      DatabaseTab.open: 7,
      DatabaseTab.restricted: 3,
      DatabaseTab.personal: 2,
      DatabaseTab.drafts: 1,
      DatabaseTab.deleted: 0,
    };

    Future<void> pumpTabs(
      WidgetTester tester, {
      DatabaseTab selected = DatabaseTab.all,
      ValueChanged<DatabaseTab>? onSelected,
      Size size = const Size(1000, 600),
    }) => _pump(
      tester,
      DatabaseTabsBar(
        counts: counts,
        selected: selected,
        onSelected: onSelected ?? (_) {},
      ),
      size: size,
    );

    testWidgets('shows every tab with its live counter', (tester) async {
      await pumpTabs(tester);

      for (final tab in DatabaseTab.values) {
        expect(find.text(tab.label), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(ValueKey('tab-${tab.name}')),
            matching: find.text('${counts[tab]}'),
          ),
          findsOneWidget,
        );
      }
    });

    testWidgets('only the selected counter is yellow', (tester) async {
      await pumpTabs(tester, selected: DatabaseTab.drafts);

      Color? boxColor(DatabaseTab tab) {
        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byKey(ValueKey('tab-${tab.name}')),
                matching: find.byType(Container),
              )
              .first,
        );
        return (container.decoration as BoxDecoration).color;
      }

      expect(boxColor(DatabaseTab.drafts), ColorManager.accent);
      expect(boxColor(DatabaseTab.all), isNot(ColorManager.accent));
      expect(boxColor(DatabaseTab.open), isNot(ColorManager.accent));
    });

    testWidgets('tapping a tab reports it', (tester) async {
      final tapped = <DatabaseTab>[];
      await pumpTabs(tester, onSelected: tapped.add);

      await tester.tap(find.text('Restricted'));
      await tester.tap(find.text('Deleted'));

      expect(tapped, [DatabaseTab.restricted, DatabaseTab.deleted]);
    });

    testWidgets('scrolls horizontally on a narrow screen without overflow', (
      tester,
    ) async {
      await pumpTabs(tester, size: const Size(320, 600));

      expect(tester.takeException(), isNull);
      // the last tab is off screen until scrolled
      await tester.scrollUntilVisible(
        find.text('Deleted'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Deleted'), findsOneWidget);
    });
  });

  group('SortMenuButton', () {
    testWidgets('lists both options and reports the choice', (tester) async {
      DatabaseSort? chosen;
      await _pump(
        tester,
        SortMenuButton(
          selected: DatabaseSort.creationDate,
          onSelected: (sort) => chosen = sort,
        ),
      );
      expect(find.text('Sort'), findsOneWidget);
      expect(find.text('Last Update'), findsNothing);

      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();
      expect(find.text('Creation Date'), findsOneWidget);
      expect(find.text('Last Update'), findsOneWidget);

      await tester.tap(find.text('Last Update'));
      await tester.pumpAndSettle();

      expect(chosen, DatabaseSort.lastUpdate);
    });

    testWidgets('highlights the active option', (tester) async {
      await _pump(
        tester,
        SortMenuButton(selected: DatabaseSort.lastUpdate, onSelected: (_) {}),
      );
      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();

      Color? background(String label) {
        final button = tester.widget<MenuItemButton>(
          find.widgetWithText(MenuItemButton, label),
        );
        return button.style?.backgroundColor?.resolve({});
      }

      expect(background('Last Update'), AppColors.light.lightGrey);
      expect(background('Creation Date'), isNull);
    });

    testWidgets('can hide its label (compact screens)', (tester) async {
      await _pump(
        tester,
        SortMenuButton(
          selected: DatabaseSort.creationDate,
          onSelected: (_) {},
          showLabel: false,
        ),
      );

      expect(find.text('Sort'), findsNothing);
      expect(find.byIcon(Icons.sort), findsOneWidget);
    });
  });

  group('DatabaseFilterPanel', () {
    testWidgets('Apply reports the chosen access type', (tester) async {
      AccessType? applied = AccessType.open;
      await _pump(
        tester,
        DatabaseFilterPanel(onApply: (type) => applied = type, onReset: () {}),
      );
      expect(find.text('Access Type'), findsOneWidget);

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Personal Access').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));

      expect(applied, AccessType.personal);
    });

    testWidgets('choosing All applies no filter', (tester) async {
      AccessType? applied = AccessType.open;
      await _pump(
        tester,
        DatabaseFilterPanel(
          initialAccessType: AccessType.restricted,
          onApply: (type) => applied = type,
          onReset: () {},
        ),
      );
      expect(find.text('Restricted Access'), findsOneWidget);

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));

      expect(applied, isNull);
    });

    testWidgets('Reset clears the selection and calls back', (tester) async {
      var resets = 0;
      await _pump(
        tester,
        DatabaseFilterPanel(
          initialAccessType: AccessType.restricted,
          onApply: (_) {},
          onReset: () => resets++,
        ),
      );

      await tester.tap(find.text('Reset'));
      await tester.pump();

      expect(resets, 1);
      expect(find.text('Restricted Access'), findsNothing);
      expect(find.text('Access Type'), findsOneWidget);
    });
  });
}
