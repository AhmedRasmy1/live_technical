import 'package:injectable/injectable.dart';

import '../../../../core/common/api_result.dart';
import '../../domain/entities/database_entity.dart';
import '../../domain/repo/database_repo.dart';
import '../data_sources/database_data_source.dart';

@Injectable(as: DatabaseRepo)
class DatabaseRepoImpl implements DatabaseRepo {
  DatabaseDataSource databaseDataSource;

  DatabaseRepoImpl(this.databaseDataSource);

  @override
  Future<Result<List<DatabaseEntity>>> getDatabases() {
    return databaseDataSource.getDatabases();
  }

  @override
  Future<Result<DatabaseEntity>> createDatabase(
    DatabaseEntity database,
    List<String> employeeIds,
  ) {
    return databaseDataSource.createDatabase(database, employeeIds);
  }
}
