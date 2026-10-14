import 'package:injectable/injectable.dart';

import '../../../../core/common/api_result.dart';
import '../entities/database_entity.dart';
import '../repo/database_repo.dart';

@injectable
class GetDatabasesUseCase {
  DatabaseRepo databaseRepo;

  GetDatabasesUseCase(this.databaseRepo);

  Future<Result<List<DatabaseEntity>>> getDatabases() {
    return databaseRepo.getDatabases();
  }
}
