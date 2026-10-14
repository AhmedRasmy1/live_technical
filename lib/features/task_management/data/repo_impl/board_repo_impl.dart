import 'package:injectable/injectable.dart';

import '../../../../core/common/api_result.dart';
import '../../../hr/domain/entities/employee_entity.dart';
import '../../domain/entities/board_entity.dart';
import '../../domain/repo/board_repo.dart';
import '../data_sources/board_data_source.dart';

@Injectable(as: BoardRepo)
class BoardRepoImpl implements BoardRepo {
  BoardDataSource boardDataSource;

  BoardRepoImpl(this.boardDataSource);

  @override
  Future<Result<BoardEntity>> createBoard(BoardEntity board) {
    return boardDataSource.createBoard(board);
  }

  @override
  Future<Result<bool>> checkBoardExists(String boardName) {
    return boardDataSource.checkBoardExists(boardName);
  }

  @override
  Future<Result<List<EmployeeEntity>>> getEmployees() {
    return boardDataSource.getEmployees();
  }
}
