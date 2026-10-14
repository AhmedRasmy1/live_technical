import 'dart:async';

import 'package:live_technical/core/common/api_result.dart';
import 'package:live_technical/core/di/di.dart';
import 'package:live_technical/features/hr/domain/entities/employee_entity.dart';
import 'package:live_technical/features/task_management/domain/entities/board_entity.dart';
import 'package:live_technical/features/task_management/domain/repo/board_repo.dart';
import 'package:live_technical/features/task_management/domain/usecases/check_board_exists_use_case.dart';
import 'package:live_technical/features/task_management/domain/usecases/create_board_use_case.dart';
import 'package:live_technical/features/task_management/domain/usecases/get_board_employees_use_case.dart';
import 'package:live_technical/features/task_management/presentation/viewmodels/create_board_cubit/create_board_cubit.dart';

/// In-memory repo that behaves like Firestore for tests.
class FakeBoardRepo implements BoardRepo {
  FakeBoardRepo({List<EmployeeEntity>? employees, List<BoardEntity>? boards})
    : employees = employees ?? [],
      boards = boards ?? [];

  final List<EmployeeEntity> employees;
  final List<BoardEntity> boards;

  Exception? employeesError;
  Exception? checkError;
  Exception? createError;

  /// When set, `createBoard` waits for it (to observe the loading state).
  Completer<void>? createGate;

  int employeeCalls = 0;
  int checkCalls = 0;
  int createCalls = 0;

  @override
  Future<Result<List<EmployeeEntity>>> getEmployees() async {
    employeeCalls++;
    final error = employeesError;
    if (error != null) return Fail(error);
    return Success(List.of(employees));
  }

  @override
  Future<Result<bool>> checkBoardExists(String boardName) async {
    checkCalls++;
    final error = checkError;
    if (error != null) return Fail(error);
    return Success(boards.any((board) => board.boardName == boardName));
  }

  @override
  Future<Result<BoardEntity>> createBoard(BoardEntity board) async {
    createCalls++;
    if (createGate != null) await createGate!.future;
    final error = createError;
    if (error != null) return Fail(error);
    final saved = BoardEntity(
      id: 'board-$createCalls',
      boardName: board.boardName,
      boardNameAr: board.boardNameAr,
      description: board.description,
      descriptionAr: board.descriptionAr,
      departments: board.departments,
      isMessagingEnabled: board.isMessagingEnabled,
      assignedEmployeeIds: board.assignedEmployeeIds,
    );
    boards.add(saved);
    return Success(saved);
  }
}

EmployeeEntity employeeOf(
  String id,
  String first,
  String last,
  String department,
  String jobTitle,
) => EmployeeEntity(
  id: id,
  firstName: first,
  lastName: last,
  department: department,
  jobTitle: jobTitle,
);

/// 4 employees: 2 Marketing, 1 HR, 1 Design.
List<EmployeeEntity> boardEmployees() => [
  employeeOf('e1', 'Amro', 'Handousa', 'Marketing', 'Manager'),
  employeeOf('e2', 'Sara', 'Ahmed', 'HR', 'Specialist'),
  employeeOf('e3', 'Mona', 'Adel', 'Marketing', 'Designer'),
  employeeOf('e4', 'Omar', 'Khaled', 'Design', 'Artist'),
];

CreateBoardCubit buildCreateBoardCubit(FakeBoardRepo repo) => CreateBoardCubit(
  GetBoardEmployeesUseCase(repo),
  CheckBoardExistsUseCase(repo),
  CreateBoardUseCase(repo),
);

/// Registers the cubit on the shared `getIt` with a fake repo.
void registerBoardDependencies(FakeBoardRepo repo) {
  getIt.registerFactory<CreateBoardCubit>(() => buildCreateBoardCubit(repo));
}
