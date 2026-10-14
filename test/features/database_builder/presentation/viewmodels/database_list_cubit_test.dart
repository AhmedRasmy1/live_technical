import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/common/custom_exception.dart';
import 'package:live_technical/features/database_builder/domain/entities/database_entity.dart';
import 'package:live_technical/features/database_builder/domain/entities/database_enums.dart';
import 'package:live_technical/features/database_builder/presentation/viewmodels/database_list_cubit/database_list_cubit.dart';

import '../../test_support.dart';

void main() {
  late FakeDatabaseRepo repo;
  late DatabaseListCubit cubit;

  setUp(() {
    repo = FakeDatabaseRepo(databases: sampleDatabases());
    cubit = buildDatabaseListCubit(repo);
  });

  tearDown(() => cubit.close());

  List<String> titles() =>
      cubit.data.visibleDatabases.map((d) => d.title).toList();

  group('loading', () {
    test('starts empty on the All tab, sorted by creation date', () {
      expect(cubit.state, isA<DatabaseListInitial>());
      expect(cubit.data.databases, isEmpty);
      expect(cubit.data.tab, DatabaseTab.all);
      expect(cubit.data.sort, DatabaseSort.creationDate);
    });

    test(
      'getDatabases emits Loading then Success with the databases',
      () async {
        final states = <DatabaseListState>[];
        final sub = cubit.stream.listen(states.add);

        await cubit.getDatabases();
        await Future<void>.delayed(Duration.zero);

        expect(states[0], isA<DatabaseListLoading>());
        expect(states[1], isA<DatabaseListSuccess>());
        expect(cubit.data.databases, hasLength(7));
        expect(repo.getCalls, 1);
        await sub.cancel();
      },
    );

    test(
      'a failure emits the readable message and keeps the old list',
      () async {
        await cubit.getDatabases();
        repo.getError = NoInternetError();

        await cubit.getDatabases();

        final state = cubit.state as DatabaseListFailure;
        expect(state.error, 'please check internet connection');
        expect(state.data.databases, hasLength(7));
      },
    );

    test('a Firestore error shows its message', () async {
      repo.getError = FirestoreError('permission-denied');

      await cubit.getDatabases();

      expect((cubit.state as DatabaseListFailure).error, 'permission-denied');
    });
  });

  group('live counters', () {
    setUp(() async => cubit.getDatabases());

    test('count every tab from the loaded databases', () {
      final counts = cubit.data.counts;

      expect(counts[DatabaseTab.all], 7);
      expect(counts[DatabaseTab.open], 3); // Alpha, Bravo, Golf
      expect(counts[DatabaseTab.restricted], 1);
      expect(counts[DatabaseTab.personal], 1);
      expect(counts[DatabaseTab.drafts], 1);
      expect(counts[DatabaseTab.deleted], 1);
    });

    test('are not changed by the selected tab or the search text', () {
      cubit.selectTab(DatabaseTab.deleted);
      cubit.searchDatabases('alpha');

      expect(cubit.data.counts[DatabaseTab.all], 7);
      expect(cubit.data.counts[DatabaseTab.open], 3);
    });

    test('update after a refresh with a new database', () async {
      await cubit.getDatabases();
      expect(cubit.data.counts[DatabaseTab.drafts], 1);

      repo.databases.add(
        databaseOf(
          'Hotel',
          status: DatabaseStatus.draft,
          created: DateTime(2024, 2, 1),
        ),
      );
      await cubit.getDatabases();

      expect(cubit.data.counts[DatabaseTab.drafts], 2);
      expect(cubit.data.counts[DatabaseTab.all], 8);
    });

    test('are zero before anything is loaded', () {
      final fresh = buildDatabaseListCubit(repo);

      expect(fresh.data.counts.values, everyElement(0));
      fresh.close();
    });
  });

  group('tabs', () {
    setUp(() async => cubit.getDatabases());

    test('All shows everything including drafts and deleted', () {
      expect(cubit.data.visibleDatabases, hasLength(7));
    });

    test('each tab shows only its status', () {
      cubit.selectTab(DatabaseTab.open);
      expect(titles(), unorderedEquals(['Alpha', 'Bravo', 'Golf']));

      cubit.selectTab(DatabaseTab.restricted);
      expect(titles(), ['Charlie']);

      cubit.selectTab(DatabaseTab.personal);
      expect(titles(), ['Delta']);

      cubit.selectTab(DatabaseTab.drafts);
      expect(titles(), ['Echo']);

      cubit.selectTab(DatabaseTab.deleted);
      expect(titles(), ['Foxtrot']);

      cubit.selectTab(DatabaseTab.all);
      expect(titles(), hasLength(7));
    });

    test('selecting a tab emits Success', () {
      cubit.selectTab(DatabaseTab.drafts);

      expect(cubit.state, isA<DatabaseListSuccess>());
      expect(cubit.data.tab, DatabaseTab.drafts);
    });

    test('the tab stays selected after a refresh', () async {
      cubit.selectTab(DatabaseTab.personal);

      await cubit.getDatabases();

      expect(cubit.data.tab, DatabaseTab.personal);
      expect(titles(), ['Delta']);
    });
  });

  group('search', () {
    setUp(() async => cubit.getDatabases());

    test('matches the title, ignoring case', () {
      cubit.searchDatabases('ALP');

      expect(titles(), ['Alpha']);
    });

    test('matches anywhere in the title', () {
      cubit.searchDatabases('lt');

      expect(titles(), ['Delta']);
    });

    test('matches the Arabic title', () async {
      repo.databases.add(
        databaseOf('Hotel', titleAr: 'فندق', created: DateTime(2024, 2, 1)),
      );
      await cubit.getDatabases();

      cubit.searchDatabases('فندق');

      expect(titles(), ['Hotel']);
    });

    test('trims the text and an empty search shows everything', () {
      cubit.searchDatabases('  alpha  ');
      expect(titles(), ['Alpha']);

      cubit.searchDatabases('   ');
      expect(titles(), hasLength(7));
    });

    test('no match gives an empty list', () {
      cubit.searchDatabases('zzz');

      expect(titles(), isEmpty);
    });

    test('works together with the tab', () {
      cubit.selectTab(DatabaseTab.open);
      cubit.searchDatabases('o'); // Bravo, Golf (Alpha has no "o")

      expect(titles(), unorderedEquals(['Bravo', 'Golf']));

      cubit.selectTab(DatabaseTab.deleted);
      expect(titles(), ['Foxtrot']);
    });
  });

  group('sorting', () {
    setUp(() async => cubit.getDatabases());

    test('by creation date, newest first (default)', () {
      expect(titles(), [
        'Golf',
        'Foxtrot',
        'Echo',
        'Delta',
        'Charlie',
        'Bravo',
        'Alpha',
      ]);
    });

    test(
      'by last update, newest first; never-edited use the creation date',
      () {
        cubit.sortBy(DatabaseSort.lastUpdate);

        // Bravo edited 20 Jan, Echo 15 Jan, then created: Golf 7, Foxtrot 6 ...
        expect(titles(), [
          'Bravo',
          'Echo',
          'Golf',
          'Foxtrot',
          'Delta',
          'Charlie',
          'Alpha',
        ]);
      },
    );

    test('switching back restores the creation order', () {
      cubit.sortBy(DatabaseSort.lastUpdate);
      cubit.sortBy(DatabaseSort.creationDate);

      expect(titles().first, 'Golf');
    });

    test('databases without a date go last', () async {
      repo.databases.add(databaseOf('NoDate'));
      await cubit.getDatabases();

      expect(titles().last, 'NoDate');
      cubit.sortBy(DatabaseSort.lastUpdate);
      expect(titles().last, 'NoDate');
    });

    test('sort applies inside the selected tab', () {
      cubit.selectTab(DatabaseTab.open);
      cubit.sortBy(DatabaseSort.lastUpdate);

      expect(titles(), ['Bravo', 'Golf', 'Alpha']);
    });

    test('the sort stays after a refresh', () async {
      cubit.sortBy(DatabaseSort.lastUpdate);

      await cubit.getDatabases();

      expect(cubit.data.sort, DatabaseSort.lastUpdate);
    });

    test('does not change the stored list', () {
      cubit.sortBy(DatabaseSort.lastUpdate);

      expect(cubit.data.databases.first.title, 'Alpha');
    });
  });

  group('access type filter', () {
    // Every sample database is restricted except these overrides.
    setUp(() async {
      repo.databases
        ..clear()
        ..addAll([
          databaseOf('Open1', created: DateTime(2024, 1, 1)),
          DatabaseEntity(
            id: 'p1',
            title: 'Personal1',
            accessType: AccessType.personal,
            status: DatabaseStatus.personal,
            creationDate: DateTime(2024, 1, 2),
          ),
          DatabaseEntity(
            id: 'p2',
            title: 'Personal2',
            accessType: AccessType.personal,
            status: DatabaseStatus.draft,
            creationDate: DateTime(2024, 1, 3),
          ),
        ]);
      await cubit.getDatabases();
    });

    test('shows only the chosen access type', () {
      cubit.filterByAccessType(AccessType.personal);

      expect(titles(), unorderedEquals(['Personal1', 'Personal2']));
      expect(cubit.state, isA<DatabaseListSuccess>());
    });

    test('null clears the filter', () {
      cubit.filterByAccessType(AccessType.personal);
      cubit.filterByAccessType(null);

      expect(cubit.data.accessFilter, isNull);
      expect(titles(), hasLength(3));
    });

    test('works together with the tab and the search', () {
      cubit.filterByAccessType(AccessType.personal);
      cubit.selectTab(DatabaseTab.drafts);
      expect(titles(), ['Personal2']);

      cubit.selectTab(DatabaseTab.all);
      cubit.searchDatabases('1');
      expect(titles(), ['Personal1']);
    });

    test('does not change the tab counters', () {
      cubit.filterByAccessType(AccessType.personal);

      expect(cubit.data.counts[DatabaseTab.all], 3);
    });

    test('stays after a refresh', () async {
      cubit.filterByAccessType(AccessType.open);

      await cubit.getDatabases();

      expect(cubit.data.accessFilter, AccessType.open);
      expect(titles(), isEmpty); // databaseOf() builds restricted databases
    });
  });

  test('tab and sort labels match the design', () {
    expect(DatabaseTab.values.map((t) => t.label), [
      'All',
      'Open',
      'Restricted',
      'Personal',
      'Drafts',
      'Deleted',
    ]);
    expect(DatabaseSort.values.map((s) => s.label), [
      'Creation Date',
      'Last Update',
    ]);
  });
}
