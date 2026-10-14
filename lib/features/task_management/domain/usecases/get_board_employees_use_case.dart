import 'package:injectable/injectable.dart';

import '../../../../core/common/api_result.dart';
import '../../../hr/domain/entities/employee_entity.dart';
import '../repo/board_repo.dart';

@injectable
class GetBoardEmployeesUseCase {
  BoardRepo boardRepo;

  GetBoardEmployeesUseCase(this.boardRepo);

  Future<Result<List<EmployeeEntity>>> getEmployees() {
    return boardRepo.getEmployees();
  }
}
