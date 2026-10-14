import '../../../../core/common/api_result.dart';
import '../../domain/entities/database_entity.dart';

abstract class DatabaseDataSource {
  Future<Result<List<DatabaseEntity>>> getDatabases();

  /// Writes the database document and one access document per employee in a
  /// single Firestore batch (all or nothing).
  Future<Result<DatabaseEntity>> createDatabase(
    DatabaseEntity database,
    List<String> employeeIds,
  );
}
