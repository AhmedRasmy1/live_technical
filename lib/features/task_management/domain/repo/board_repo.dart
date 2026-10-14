import '../../../../core/common/api_result.dart';
import '../../../hr/domain/entities/employee_entity.dart';
import '../entities/board_entity.dart';

abstract class BoardRepo {
  Future<Result<BoardEntity>> createBoard(BoardEntity board);

  /// `true` when a board with exactly this name already exists.
  Future<Result<bool>> checkBoardExists(String boardName);

  Future<Result<List<EmployeeEntity>>> getEmployees();
}
