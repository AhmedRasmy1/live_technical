import 'package:injectable/injectable.dart';

import '../../../../core/common/api_result.dart';
import '../entities/database_entity.dart';
import '../repo/database_repo.dart';

@injectable
class CreateDatabaseUseCase {
  DatabaseRepo databaseRepo;

  CreateDatabaseUseCase(this.databaseRepo);

  Future<Result<DatabaseEntity>> createDatabase(
    DatabaseEntity database,
    List<String> employeeIds,
  ) {
    return databaseRepo.createDatabase(database, employeeIds);
  }
}
