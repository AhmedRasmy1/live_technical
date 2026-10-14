import '../../../../core/common/api_result.dart';
import '../../../hr/domain/entities/employee_entity.dart';
import '../../domain/entities/board_entity.dart';

abstract class BoardDataSource {
  Future<Result<BoardEntity>> createBoard(BoardEntity board);

  Future<Result<bool>> checkBoardExists(String boardName);

  Future<Result<List<EmployeeEntity>>> getEmployees();
}
