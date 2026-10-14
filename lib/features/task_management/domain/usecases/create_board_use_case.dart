import 'package:injectable/injectable.dart';

import '../../../../core/common/api_result.dart';
import '../entities/board_entity.dart';
import '../repo/board_repo.dart';

@injectable
class CreateBoardUseCase {
  BoardRepo boardRepo;

  CreateBoardUseCase(this.boardRepo);

  Future<Result<BoardEntity>> createBoard(BoardEntity board) {
    return boardRepo.createBoard(board);
  }
}
