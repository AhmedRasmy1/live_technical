import 'dart:async';

import 'package:live_technical/core/common/api_result.dart';
import 'package:live_technical/features/database_builder/domain/entities/database_entity.dart';
import 'package:live_technical/features/database_builder/domain/entities/database_enums.dart';
import 'package:live_technical/features/database_builder/domain/repo/database_repo.dart';
import 'package:live_technical/features/database_builder/domain/usecases/create_database_use_case.dart';
import 'package:live_technical/features/database_builder/domain/usecases/get_databases_use_case.dart';
import 'package:live_technical/features/database_builder/presentation/viewmodels/create_database_cubit/create_database_cubit.dart';
import 'package:live_technical/features/database_builder/presentation/viewmodels/database_list_cubit/database_list_cubit.dart';
import 'package:live_technical/features/hr/domain/entities/employee_entity.dart';
import 'package:live_technical/features/hr/domain/usecases/get_employees_use_case.dart';

import '../hr/test_support.dart';

/// In-memory repo that behaves like Firestore for tests.
class FakeDatabaseRepo implements DatabaseRepo {
  FakeDatabaseRepo({List<DatabaseEntity>? databases})
    : databases = databases ?? [];

  final List<DatabaseEntity> databases;
  Exception? getError;
  Exception? createError;

  /// When set, `createDatabase` waits for it (to observe the loading state).
  Completer<void>? createGate;

  int getCalls = 0;
  int createCalls = 0;
  DatabaseEntity? lastDatabase;
  List<String>? lastEmployeeIds;

  @override
  Future<Result<List<DatabaseEntity>>> getDatabases() async {
    getCalls++;
    final error = getError;
    if (error != null) return Fail(error);
    return Success(List.of(databases));
  }

  @override
  Future<Result<DatabaseEntity>> createDatabase(
    DatabaseEntity database,
    List<String> employeeIds,
  ) async {
    createCalls++;
    lastDatabase = database;
    lastEmployeeIds = List.of(employeeIds);
    if (createGate != null) await createGate!.future;
    final error = createError;
    if (error != null) return Fail(error);
    final saved = DatabaseEntity(
      id: 'db-$createCalls',
      title: database.title,
      titleAr: database.titleAr,
      description: database.description,
      descriptionAr: database.descriptionAr,
      tablesCount: database.tablesCount,
      accessType: database.accessType,
      permissions: database.permissions,
      startDate: database.startDate,
      endDate: database.endDate,
      status: database.status,
      assignedEmployeeIds: employeeIds,
    );
    databases.insert(0, saved);
    return Success(saved);
  }
}

DatabaseEntity databaseOf(
  String title, {
  DatabaseStatus status = DatabaseStatus.open,
  String titleAr = '',
  DateTime? created,
  DateTime? edited,
  DateTime? deleted,
}) => DatabaseEntity(
  id: title.toLowerCase().replaceAll(' ', '-'),
  title: title,
  titleAr: titleAr,
  accessType: AccessType.restricted,
  status: status,
  creationDate: created,
  lastEditDate: edited,
  deletedDate: deleted,
);

/// 7 databases covering every status. `created` goes 1..7 Jan 2024
/// (Alpha oldest, Golf newest); only Bravo and Echo were edited later.
///
/// | title | status     | created | edited |
/// | Alpha | open       | 1 Jan   | -      |
/// | Bravo | open       | 2 Jan   | 20 Jan |
/// | Charlie | restricted | 3 Jan | -      |
/// | Delta | personal   | 4 Jan   | -      |
/// | Echo  | draft      | 5 Jan   | 15 Jan |
/// | Foxtrot | deleted  | 6 Jan   | -      |
/// | Golf  | open       | 7 Jan   | -      |
List<DatabaseEntity> sampleDatabases() => [
  databaseOf('Alpha', created: DateTime(2024, 1, 1)),
  databaseOf(
    'Bravo',
    created: DateTime(2024, 1, 2),
    edited: DateTime(2024, 1, 20),
  ),
  databaseOf(
    'Charlie',
    status: DatabaseStatus.restricted,
    created: DateTime(2024, 1, 3),
  ),
  databaseOf(
    'Delta',
    status: DatabaseStatus.personal,
    created: DateTime(2024, 1, 4),
  ),
  databaseOf(
    'Echo',
    status: DatabaseStatus.draft,
    created: DateTime(2024, 1, 5),
    edited: DateTime(2024, 1, 15),
  ),
  databaseOf(
    'Foxtrot',
    status: DatabaseStatus.deleted,
    created: DateTime(2024, 1, 6),
    deleted: DateTime(2024, 1, 10),
  ),
  databaseOf('Golf', created: DateTime(2024, 1, 7)),
];

DatabaseListCubit buildDatabaseListCubit(FakeDatabaseRepo repo) =>
    DatabaseListCubit(GetDatabasesUseCase(repo));

/// 4 employees: 2 Marketing, 1 HR, 1 Design.
List<EmployeeEntity> wizardEmployees() => [
  const EmployeeEntity(
    id: 'e1',
    firstName: 'Amro',
    lastName: 'Handousa',
    department: 'Marketing',
    jobTitle: 'Manager',
  ),
  const EmployeeEntity(
    id: 'e2',
    firstName: 'Sara',
    lastName: 'Ahmed',
    department: 'HR',
    jobTitle: 'Specialist',
  ),
  const EmployeeEntity(
    id: 'e3',
    firstName: 'Mona',
    lastName: 'Adel',
    department: 'Marketing',
    jobTitle: 'Designer',
  ),
  const EmployeeEntity(
    id: 'e4',
    firstName: 'Omar',
    lastName: 'Khaled',
    department: 'Design',
    jobTitle: 'Artist',
  ),
];

CreateDatabaseCubit buildCreateDatabaseCubit(
  FakeDatabaseRepo databaseRepo,
  FakeEmployeeRepo employeeRepo,
) => CreateDatabaseCubit(
  GetEmployeesUseCase(employeeRepo),
  CreateDatabaseUseCase(databaseRepo),
);
