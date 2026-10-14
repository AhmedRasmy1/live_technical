import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

import '../../../../../core/common/api_result.dart';
import '../../../../../core/utils/extract_error_message.dart';
import '../../../domain/entities/database_entity.dart';
import '../../../domain/entities/database_enums.dart';
import '../../../domain/usecases/get_databases_use_case.dart';

part 'database_list_state.dart';

@injectable
class DatabaseListCubit extends Cubit<DatabaseListState> {
  final GetDatabasesUseCase _getDatabasesUseCase;

  DatabaseListCubit(this._getDatabasesUseCase)
    : super(const DatabaseListInitial(DatabaseListData()));

  DatabaseListData get data => state.data;

  /// Loads (or reloads) the databases. The selected tab, search text and sort
  /// are kept, so a refresh after creating a database updates the counters
  /// without losing the user's view.
  Future<void> getDatabases() async {
    emit(DatabaseListLoading(data));
    final result = await _getDatabasesUseCase.getDatabases();
    switch (result) {
      case Success<List<DatabaseEntity>>():
        emit(DatabaseListSuccess(data.copyWith(databases: result.data)));
        break;
      case Fail<List<DatabaseEntity>>():
        emit(DatabaseListFailure(data, extractErrorMessage(result.exception)));
        break;
    }
  }

  void selectTab(DatabaseTab tab) {
    emit(DatabaseListSuccess(data.copyWith(tab: tab)));
  }

  void searchDatabases(String query) {
    emit(DatabaseListSuccess(data.copyWith(query: query.trim())));
  }

  /// `null` removes the filter.
  void filterByAccessType(AccessType? accessType) {
    emit(
      DatabaseListSuccess(
        accessType == null
            ? data.copyWith(clearAccessFilter: true)
            : data.copyWith(accessFilter: accessType),
      ),
    );
  }

  void sortBy(DatabaseSort sort) {
    emit(DatabaseListSuccess(data.copyWith(sort: sort)));
  }
}
