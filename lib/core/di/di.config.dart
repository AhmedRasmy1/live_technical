// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/database_builder/data/data_sources/database_data_source.dart'
    as _i722;
import '../../features/database_builder/data/data_sources_impl/database_data_source_impl.dart'
    as _i726;
import '../../features/database_builder/data/repo_impl/database_repo_impl.dart'
    as _i510;
import '../../features/database_builder/domain/repo/database_repo.dart'
    as _i767;
import '../../features/database_builder/domain/usecases/create_database_use_case.dart'
    as _i777;
import '../../features/database_builder/domain/usecases/get_databases_use_case.dart'
    as _i794;
import '../../features/database_builder/presentation/viewmodels/create_database_cubit/create_database_cubit.dart'
    as _i454;
import '../../features/database_builder/presentation/viewmodels/database_list_cubit/database_list_cubit.dart'
    as _i273;
import '../../features/hr/data/data_sources/employee_data_source.dart' as _i47;
import '../../features/hr/data/data_sources_impl/employee_data_source_impl.dart'
    as _i825;
import '../../features/hr/data/repo_impl/employee_repo_impl.dart' as _i562;
import '../../features/hr/domain/repo/employee_repo.dart' as _i278;
import '../../features/hr/domain/usecases/add_employee_use_case.dart' as _i306;
import '../../features/hr/domain/usecases/get_employees_use_case.dart' as _i26;
import '../../features/hr/presentation/viewmodels/add_employee_cubit/add_employee_cubit.dart'
    as _i508;
import '../../features/hr/presentation/viewmodels/employee_list_cubit/employee_list_cubit.dart'
    as _i538;
import '../../features/task_management/data/data_sources/board_data_source.dart'
    as _i755;
import '../../features/task_management/data/data_sources_impl/board_data_source_impl.dart'
    as _i89;
import '../../features/task_management/data/repo_impl/board_repo_impl.dart'
    as _i418;
import '../../features/task_management/domain/repo/board_repo.dart' as _i365;
import '../../features/task_management/domain/usecases/check_board_exists_use_case.dart'
    as _i669;
import '../../features/task_management/domain/usecases/create_board_use_case.dart'
    as _i314;
import '../../features/task_management/domain/usecases/get_board_employees_use_case.dart'
    as _i328;
import '../../features/task_management/presentation/viewmodels/create_board_cubit/create_board_cubit.dart'
    as _i470;
import '../api/api_manager/api_manager.dart' as _i680;
import '../api/dio_module.dart' as _i784;
import '../theme/theme_cubit/theme_cubit.dart' as _i613;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioModule = _$DioModule();
    gh.lazySingleton<_i361.Dio>(() => dioModule.providerDio());
    gh.lazySingleton<_i613.ThemeCubit>(() => _i613.ThemeCubit());
    gh.factory<_i47.EmployeeDataSource>(() => _i825.EmployeeDataSourceImpl());
    gh.factory<_i722.DatabaseDataSource>(() => _i726.DatabaseDataSourceImpl());
    gh.factory<_i680.ApiService>(() => _i680.ApiService(gh<_i361.Dio>()));
    gh.factory<_i755.BoardDataSource>(() => _i89.BoardDataSourceImpl());
    gh.factory<_i767.DatabaseRepo>(
      () => _i510.DatabaseRepoImpl(gh<_i722.DatabaseDataSource>()),
    );
    gh.factory<_i365.BoardRepo>(
      () => _i418.BoardRepoImpl(gh<_i755.BoardDataSource>()),
    );
    gh.factory<_i278.EmployeeRepo>(
      () => _i562.EmployeeRepoImpl(gh<_i47.EmployeeDataSource>()),
    );
    gh.factory<_i777.CreateDatabaseUseCase>(
      () => _i777.CreateDatabaseUseCase(gh<_i767.DatabaseRepo>()),
    );
    gh.factory<_i794.GetDatabasesUseCase>(
      () => _i794.GetDatabasesUseCase(gh<_i767.DatabaseRepo>()),
    );
    gh.factory<_i273.DatabaseListCubit>(
      () => _i273.DatabaseListCubit(gh<_i794.GetDatabasesUseCase>()),
    );
    gh.factory<_i669.CheckBoardExistsUseCase>(
      () => _i669.CheckBoardExistsUseCase(gh<_i365.BoardRepo>()),
    );
    gh.factory<_i314.CreateBoardUseCase>(
      () => _i314.CreateBoardUseCase(gh<_i365.BoardRepo>()),
    );
    gh.factory<_i328.GetBoardEmployeesUseCase>(
      () => _i328.GetBoardEmployeesUseCase(gh<_i365.BoardRepo>()),
    );
    gh.factory<_i306.AddEmployeeUseCase>(
      () => _i306.AddEmployeeUseCase(gh<_i278.EmployeeRepo>()),
    );
    gh.factory<_i26.GetEmployeesUseCase>(
      () => _i26.GetEmployeesUseCase(gh<_i278.EmployeeRepo>()),
    );
    gh.factory<_i470.CreateBoardCubit>(
      () => _i470.CreateBoardCubit(
        gh<_i328.GetBoardEmployeesUseCase>(),
        gh<_i669.CheckBoardExistsUseCase>(),
        gh<_i314.CreateBoardUseCase>(),
      ),
    );
    gh.factory<_i538.EmployeeListCubit>(
      () => _i538.EmployeeListCubit(gh<_i26.GetEmployeesUseCase>()),
    );
    gh.factory<_i454.CreateDatabaseCubit>(
      () => _i454.CreateDatabaseCubit(
        gh<_i26.GetEmployeesUseCase>(),
        gh<_i777.CreateDatabaseUseCase>(),
      ),
    );
    gh.factory<_i508.AddEmployeeCubit>(
      () => _i508.AddEmployeeCubit(gh<_i306.AddEmployeeUseCase>()),
    );
    return this;
  }
}

class _$DioModule extends _i784.DioModule {}
