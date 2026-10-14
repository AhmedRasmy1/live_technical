import 'package:live_technical/core/di/di.dart';
import 'package:live_technical/core/theme/theme_cubit/theme_cubit.dart';
import 'package:live_technical/core/utils/cashed_data_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Registers the app-wide [ThemeCubit] (backed by an in-memory cache) for
/// screens that show a `ThemeToggleButton`. Call after `getIt.reset()`.
Future<void> registerThemeDependencies({
  Map<String, Object> saved = const {},
}) async {
  SharedPreferences.setMockInitialValues(saved);
  await CacheService.cacheInitialization();
  getIt.registerLazySingleton<ThemeCubit>(ThemeCubit.new);
}
