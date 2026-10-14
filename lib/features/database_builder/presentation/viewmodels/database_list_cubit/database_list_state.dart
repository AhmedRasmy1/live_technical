part of 'database_list_cubit.dart';

/// Dashboard tabs. [All] shows everything, including drafts and deleted.
enum DatabaseTab {
  all('All', null),
  open('Open', DatabaseStatus.open),
  restricted('Restricted', DatabaseStatus.restricted),
  personal('Personal', DatabaseStatus.personal),
  drafts('Drafts', DatabaseStatus.draft),
  deleted('Deleted', DatabaseStatus.deleted);

  const DatabaseTab(this.label, this.status);

  final String label;

  /// `null` for [all].
  final DatabaseStatus? status;

  bool matches(DatabaseEntity database) =>
      status == null || database.status == status;
}

/// Newest first for both.
enum DatabaseSort {
  creationDate('Creation Date'),
  lastUpdate('Last Update');

  const DatabaseSort(this.label);

  final String label;
}

/// Everything the dashboard shows. Every state carries it so the UI can always
/// render from `state.data` (also while reloading or after an error).
@immutable
class DatabaseListData {
  final List<DatabaseEntity> databases;
  final DatabaseTab tab;
  final String query;
  final DatabaseSort sort;

  const DatabaseListData({
    this.databases = const [],
    this.tab = DatabaseTab.all,
    this.query = '',
    this.sort = DatabaseSort.creationDate,
  });

  /// Live counter of every tab. Not affected by the search text.
  Map<DatabaseTab, int> get counts => {
    for (final tab in DatabaseTab.values)
      tab: databases.where(tab.matches).length,
  };

  /// Databases of the selected tab whose title contains the search text,
  /// sorted by [sort].
  List<DatabaseEntity> get visibleDatabases {
    final text = query.toLowerCase();
    final result = databases.where((database) {
      if (!tab.matches(database)) return false;
      if (text.isEmpty) return true;
      return database.title.toLowerCase().contains(text) ||
          database.titleAr.toLowerCase().contains(text);
    }).toList();

    DateTime? sortDate(DatabaseEntity database) => switch (sort) {
      DatabaseSort.creationDate => database.creationDate,
      // A database that was never edited was last "updated" when created.
      DatabaseSort.lastUpdate => database.lastEditDate ?? database.creationDate,
    };

    result.sort((a, b) {
      final first = sortDate(a);
      final second = sortDate(b);
      if (first == null && second == null) return 0;
      if (first == null) return 1; // unknown dates go last
      if (second == null) return -1;
      return second.compareTo(first);
    });
    return result;
  }

  DatabaseListData copyWith({
    List<DatabaseEntity>? databases,
    DatabaseTab? tab,
    String? query,
    DatabaseSort? sort,
  }) => DatabaseListData(
    databases: databases ?? this.databases,
    tab: tab ?? this.tab,
    query: query ?? this.query,
    sort: sort ?? this.sort,
  );
}

@immutable
sealed class DatabaseListState {
  final DatabaseListData data;
  const DatabaseListState(this.data);
}

final class DatabaseListInitial extends DatabaseListState {
  const DatabaseListInitial(super.data);
}

final class DatabaseListLoading extends DatabaseListState {
  const DatabaseListLoading(super.data);
}

/// Also emitted when the tab, search text or sort changes.
final class DatabaseListSuccess extends DatabaseListState {
  const DatabaseListSuccess(super.data);
}

final class DatabaseListFailure extends DatabaseListState {
  final String error;
  const DatabaseListFailure(super.data, this.error);
}
