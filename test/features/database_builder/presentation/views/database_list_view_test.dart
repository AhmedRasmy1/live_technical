import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/common/custom_exception.dart';
import 'package:live_technical/core/di/di.dart';
import 'package:live_technical/core/theme/app_colors.dart';
import 'package:live_technical/core/theme/theme_manager.dart';
import 'package:live_technical/core/widgets/breadcrumb_header.dart';
import 'package:live_technical/core/widgets/filter_dropdown.dart';
import 'package:live_technical/core/widgets/theme_toggle_button.dart';
import 'package:live_technical/features/database_builder/domain/entities/database_entity.dart';
import 'package:live_technical/features/database_builder/domain/entities/database_enums.dart';
import 'package:live_technical/features/database_builder/presentation/views/create_database_view.dart';
import 'package:live_technical/features/database_builder/presentation/views/database_list_view.dart';
import 'package:live_technical/features/database_builder/presentation/widgets/database_card.dart';
import 'package:live_technical/features/database_builder/presentation/widgets/database_filter_panel.dart';

import '../../../../core/theme/theme_test_support.dart';
import '../../../hr/test_support.dart';
import '../../test_support.dart';

void main() {
  late FakeDatabaseRepo repo;

  setUp(() async {
    repo = FakeDatabaseRepo(databases: sampleDatabases());
    registerDatabaseListDependencies(repo);
    registerCreateDatabaseDependencies(
      repo,
      FakeEmployeeRepo(employees: wizardEmployees()),
    );
    await registerThemeDependencies();
  });

  tearDown(() async => getIt.reset());

  Future<void> pumpView(
    WidgetTester tester, {
    Size size = const Size(1200, 900),
    ThemeData? theme,
    bool settle = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: theme, home: const DatabaseListView()),
    );
    if (settle) await tester.pumpAndSettle();
  }

  List<String> cardTitles(WidgetTester tester) => tester
      .widgetList<DatabaseCard>(find.byType(DatabaseCard))
      .map((card) => card.database.title)
      .toList();

  Finder tab(String name) => find.byKey(ValueKey('tab-$name'));

  Finder counter(String name, String count) =>
      find.descendant(of: tab(name), matching: find.text(count));

  group('layout', () {
    testWidgets('renders the title, tabs, action bar and every database', (
      tester,
    ) async {
      await pumpView(tester);

      expect(
        find.descendant(
          of: find.byType(BreadcrumbHeader),
          matching: find.text('Database Builder'),
        ),
        findsOneWidget,
      );
      for (final label in [
        'All',
        'Open',
        'Restricted',
        'Personal',
        'Drafts',
        'Deleted',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Filter'), findsOneWidget);
      expect(find.text('Sort'), findsOneWidget);
      expect(find.text('Create Database'), findsOneWidget);
      expect(find.byType(ThemeToggleButton), findsOneWidget);
      expect(find.byType(DatabaseCard), findsNWidgets(7));
      expect(tester.takeException(), isNull);
    });

    testWidgets('fetches the databases when it opens', (tester) async {
      await pumpView(tester);

      expect(repo.getCalls, 1);
    });

    testWidgets('shows a loader while fetching', (tester) async {
      repo.getGate = Completer<void>();
      await pumpView(tester, settle: false);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(DatabaseCard), findsNothing);

      repo.getGate!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(DatabaseCard), findsNWidgets(7));
    });

    testWidgets('shows the live counters on the tabs', (tester) async {
      await pumpView(tester);

      expect(counter('all', '7'), findsOneWidget);
      expect(counter('open', '3'), findsOneWidget);
      expect(counter('restricted', '1'), findsOneWidget);
      expect(counter('personal', '1'), findsOneWidget);
      expect(counter('drafts', '1'), findsOneWidget);
      expect(counter('deleted', '1'), findsOneWidget);
    });

    testWidgets('shows a message when there are no databases', (tester) async {
      repo.databases.clear();
      await pumpView(tester);

      expect(find.text('No databases found'), findsOneWidget);
      expect(counter('all', '0'), findsOneWidget);
    });

    testWidgets('shows the error with Retry that fetches again', (
      tester,
    ) async {
      repo.getError = NoInternetError();
      await pumpView(tester);
      expect(find.text('please check internet connection'), findsOneWidget);
      expect(find.byType(DatabaseCard), findsNothing);

      repo.getError = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.byType(DatabaseCard), findsNWidgets(7));
      expect(repo.getCalls, 2);
    });

    testWidgets('Create Database opens the creation wizard', (tester) async {
      await pumpView(tester);

      await tester.tap(find.text('Create Database'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateDatabaseView), findsOneWidget);
    });
  });

  group('tabs', () {
    testWidgets('tapping a tab filters the grid to that status', (
      tester,
    ) async {
      await pumpView(tester);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(cardTitles(tester), unorderedEquals(['Golf', 'Bravo', 'Alpha']));

      await tester.tap(find.text('Drafts'));
      await tester.pumpAndSettle();
      expect(cardTitles(tester), ['Echo']);

      await tester.tap(find.text('Deleted'));
      await tester.pumpAndSettle();
      expect(cardTitles(tester), ['Foxtrot']);
      expect(
        find.textContaining('Deleted: ', findRichText: true),
        findsOneWidget,
      );

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(find.byType(DatabaseCard), findsNWidgets(7));
    });

    testWidgets('counters stay the same while a tab is selected', (
      tester,
    ) async {
      await pumpView(tester);

      await tester.tap(find.text('Personal'));
      await tester.pumpAndSettle();

      expect(counter('all', '7'), findsOneWidget);
      expect(counter('open', '3'), findsOneWidget);
    });
  });

  group('search', () {
    testWidgets('typing filters the cards by title', (tester) async {
      await pumpView(tester);

      await tester.enterText(find.byType(TextField), 'alp');
      await tester.pumpAndSettle();

      expect(cardTitles(tester), ['Alpha']);
    });

    testWidgets('no match shows the empty message, clearing restores', (
      tester,
    ) async {
      await pumpView(tester);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('No databases found'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      expect(find.byType(DatabaseCard), findsNWidgets(7));
    });

    testWidgets('search works inside the selected tab', (tester) async {
      await pumpView(tester);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'o'); // Bravo, Golf
      await tester.pumpAndSettle();

      expect(cardTitles(tester), unorderedEquals(['Golf', 'Bravo']));
    });
  });

  group('sort', () {
    testWidgets('newest created first by default', (tester) async {
      await pumpView(tester);

      expect(cardTitles(tester).first, 'Golf');
      expect(cardTitles(tester).last, 'Alpha');
    });

    testWidgets('Last Update puts the most recently edited first', (
      tester,
    ) async {
      await pumpView(tester);

      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Last Update'));
      await tester.pumpAndSettle();

      expect(cardTitles(tester).take(2), ['Bravo', 'Echo']);

      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Creation Date'));
      await tester.pumpAndSettle();

      expect(cardTitles(tester).first, 'Golf');
    });
  });

  group('filter', () {
    Future<void> openFilter(WidgetTester tester) async {
      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();
    }

    Future<void> chooseAccess(WidgetTester tester, String label) async {
      await tester.tap(find.widgetWithText(FilterDropdown, 'Access Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    setUp(() {
      repo.databases
        ..clear()
        ..addAll([
          databaseOf('Restricted1', created: DateTime(2024, 1, 1)),
          DatabaseEntity(
            id: 'o',
            title: 'Open1',
            accessType: AccessType.open,
            status: DatabaseStatus.open,
            creationDate: DateTime(2024, 1, 2),
          ),
        ]);
    });

    testWidgets('opens and closes the filter panel', (tester) async {
      await pumpView(tester);
      expect(find.byType(DatabaseFilterPanel), findsNothing);

      await openFilter(tester);
      expect(find.byType(DatabaseFilterPanel), findsOneWidget);

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(find.byType(DatabaseFilterPanel), findsNothing);
    });

    testWidgets('Apply filters the grid by access type and closes', (
      tester,
    ) async {
      await pumpView(tester);
      await openFilter(tester);

      await chooseAccess(tester, 'Open Access');
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(find.byType(DatabaseFilterPanel), findsNothing);
      expect(cardTitles(tester), ['Open1']);
    });

    testWidgets('the panel remembers the applied filter', (tester) async {
      await pumpView(tester);
      await openFilter(tester);
      await chooseAccess(tester, 'Open Access');
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      await openFilter(tester);

      expect(
        find.descendant(
          of: find.byType(DatabaseFilterPanel),
          matching: find.text('Open Access'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Reset removes the filter', (tester) async {
      await pumpView(tester);
      await openFilter(tester);
      await chooseAccess(tester, 'Open Access');
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.byType(DatabaseCard), findsOneWidget);

      await openFilter(tester);
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(find.byType(DatabaseCard), findsNWidgets(2));
    });
  });

  group('responsive', () {
    Future<int> columnsAt(WidgetTester tester, Size size) async {
      await pumpView(tester, size: size);
      final tops = tester
          .widgetList(find.byType(DatabaseCard))
          .map((card) => tester.getTopLeft(find.byWidget(card)).dy)
          .toList();
      return tops.where((top) => top == tops.first).length;
    }

    testWidgets('1 column on a phone, 3 on a tablet, more on desktop', (
      tester,
    ) async {
      expect(await columnsAt(tester, const Size(360, 2400)), 1);
      expect(await columnsAt(tester, const Size(900, 900)), 2);
      expect(await columnsAt(tester, const Size(1100, 900)), 3);
      expect(
        await columnsAt(tester, const Size(1400, 900)),
        greaterThanOrEqualTo(4),
      );
    });

    testWidgets('the action bar stacks on a phone and keeps the Create label', (
      tester,
    ) async {
      await pumpView(tester, size: const Size(360, 900));

      expect(find.text('Create Database'), findsOneWidget);
      // Filter / Sort shrink to icons
      expect(find.text('Filter'), findsNothing);
      expect(find.text('Sort'), findsNothing);
      expect(find.byIcon(Icons.tune), findsOneWidget);
      expect(find.byIcon(Icons.sort), findsOneWidget);
      // the search sits above the buttons
      expect(
        tester.getTopLeft(find.byType(TextField)).dy <
            tester.getTopLeft(find.byIcon(Icons.tune)).dy,
        isTrue,
      );
    });

    testWidgets('does not overflow on a small phone', (tester) async {
      await pumpView(tester, size: const Size(320, 640));

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow with a large system font', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(tester.platformDispatcher.clearAllTestValues);

      await pumpView(tester, size: const Size(800, 900));

      expect(tester.takeException(), isNull);
    });
  });

  group('theme', () {
    testWidgets('uses the dark page color in dark mode', (tester) async {
      await pumpView(tester, theme: ThemeManager.dark);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.dark.background);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the toggle switches the icon', (tester) async {
      await pumpView(tester);

      await tester.tap(find.byType(ThemeToggleButton));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    });
  });
}
