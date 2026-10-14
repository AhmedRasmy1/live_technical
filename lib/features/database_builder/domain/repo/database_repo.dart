import '../../../../core/common/api_result.dart';
import '../entities/database_entity.dart';

abstract class DatabaseRepo {
  /// Every database, newest first.
  Future<Result<List<DatabaseEntity>>> getDatabases();

  /// Saves [database] together with its access list ([employeeIds]) in one
  /// atomic write: either both are stored or nothing is.
  Future<Result<DatabaseEntity>> createDatabase(
    DatabaseEntity database,
    List<String> employeeIds,
  );
}
