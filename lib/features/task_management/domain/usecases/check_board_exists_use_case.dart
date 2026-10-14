import 'package:injectable/injectable.dart';

import '../../../../core/common/api_result.dart';
import '../repo/board_repo.dart';

@injectable
class CheckBoardExistsUseCase {
  BoardRepo boardRepo;

  CheckBoardExistsUseCase(this.boardRepo);

  Future<Result<bool>> checkBoardExists(String boardName) {
    return boardRepo.checkBoardExists(boardName);
  }
}
