import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/theme/theme_cubit/theme_cubit.dart';
import 'package:live_technical/core/utils/cashed_data_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _initCache([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  await CacheService.cacheInitialization();
}

void main() {
  group('ThemeCubit', () {
    test('defaults to light when nothing is saved', () async {
      await _initCache();

      final cubit = ThemeCubit();

      expect(cubit.state, isA<ThemeInitial>());
      expect(cubit.state.themeMode, ThemeMode.light);
      expect(cubit.isDark, isFalse);
      await cubit.close();
    });

    test('restores the saved dark mode', () async {
      await _initCache({CacheConstants.themeMode: 'dark'});

      final cubit = ThemeCubit();

      expect(cubit.state.themeMode, ThemeMode.dark);
      expect(cubit.isDark, isTrue);
      await cubit.close();
    });

    test('restores the saved light mode', () async {
      await _initCache({CacheConstants.themeMode: 'light'});

      final cubit = ThemeCubit();

      expect(cubit.state.themeMode, ThemeMode.light);
      await cubit.close();
    });

    test('ignores an unknown saved value', () async {
      await _initCache({CacheConstants.themeMode: 'banana'});

      final cubit = ThemeCubit();

      expect(cubit.state.themeMode, ThemeMode.light);
      await cubit.close();
    });

    test('toggleTheme switches light -> dark -> light', () async {
      await _initCache();
      final cubit = ThemeCubit();
      final emitted = <ThemeMode>[];
      final sub = cubit.stream.listen((s) => emitted.add(s.themeMode));

      await cubit.toggleTheme();
      expect(cubit.state, isA<ThemeSuccess>());
      expect(cubit.state.themeMode, ThemeMode.dark);

      await cubit.toggleTheme();
      expect(cubit.state.themeMode, ThemeMode.light);

      await Future<void>.delayed(Duration.zero);
      expect(emitted, [ThemeMode.dark, ThemeMode.light]);
      await sub.cancel();
      await cubit.close();
    });

    test('toggleTheme saves the new mode in the cache', () async {
      await _initCache();
      final cubit = ThemeCubit();

      await cubit.toggleTheme();
      expect(CacheService.getData(key: CacheConstants.themeMode), 'dark');

      await cubit.toggleTheme();
      expect(CacheService.getData(key: CacheConstants.themeMode), 'light');
      await cubit.close();
    });

    test('a new cubit (app restart) picks up the toggled mode', () async {
      await _initCache();
      final first = ThemeCubit();
      await first.toggleTheme();
      await first.close();

      final second = ThemeCubit();

      expect(second.state.themeMode, ThemeMode.dark);
      await second.close();
    });
  });
}
