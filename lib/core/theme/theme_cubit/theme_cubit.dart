import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../utils/cashed_data_shared_preferences.dart';

part 'theme_state.dart';

/// App-wide light / dark mode. One shared instance (`getIt.get<ThemeCubit>()`),
/// so it is never closed by individual screens.
@lazySingleton
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial(_readSavedMode()));

  static const String _light = 'light';
  static const String _dark = 'dark';

  static ThemeMode _readSavedMode() {
    final saved = CacheService.getData(key: CacheConstants.themeMode);
    return saved == _dark ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDark => state.themeMode == ThemeMode.dark;

  Future<void> toggleTheme() async {
    final next = isDark ? ThemeMode.light : ThemeMode.dark;
    emit(ThemeSuccess(next));
    await CacheService.setData(
      key: CacheConstants.themeMode,
      value: next == ThemeMode.dark ? _dark : _light,
    );
  }
}
