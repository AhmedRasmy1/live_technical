import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/di/di.dart';
import 'package:live_technical/core/extensions/theme_helper.dart';
import 'package:live_technical/core/theme/app_colors.dart';
import 'package:live_technical/core/theme/theme_cubit/theme_cubit.dart';
import 'package:live_technical/core/theme/theme_manager.dart';
import 'package:live_technical/core/utils/cashed_data_shared_preferences.dart';
import 'package:live_technical/core/widgets/theme_toggle_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Same wiring as `MyApp`: MaterialApp driven by the shared ThemeCubit.
class _ThemedApp extends StatelessWidget {
  const _ThemedApp();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      bloc: getIt.get<ThemeCubit>(),
      builder: (context, state) => MaterialApp(
        theme: ThemeManager.light,
        darkTheme: ThemeManager.dark,
        themeMode: state.themeMode,
        home: Scaffold(
          appBar: AppBar(actions: const [ThemeToggleButton()]),
          body: Builder(
            builder: (context) => Container(
              key: const Key('page'),
              color: context.colors.background,
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    Map<String, Object> saved = const {},
  }) async {
    SharedPreferences.setMockInitialValues(saved);
    await CacheService.cacheInitialization();
    getIt.registerLazySingleton<ThemeCubit>(ThemeCubit.new);
    await tester.pumpWidget(const _ThemedApp());
  }

  tearDown(() async => getIt.reset());

  Color pageColor(WidgetTester tester) =>
      tester.widget<Container>(find.byKey(const Key('page'))).color!;

  testWidgets('shows the moon in light mode and the sun in dark mode', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    expect(find.byIcon(Icons.light_mode_outlined), findsNothing);
    expect(find.byTooltip('Switch to dark mode'), findsOneWidget);

    await tester.tap(find.byType(ThemeToggleButton));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_outlined), findsNothing);
    expect(find.byTooltip('Switch to light mode'), findsOneWidget);
  });

  testWidgets('tapping it switches the whole app theme and back', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.light,
    );
    expect(pageColor(tester), AppColors.light.background);

    await tester.tap(find.byType(ThemeToggleButton));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
    expect(pageColor(tester), AppColors.dark.background);

    await tester.tap(find.byType(ThemeToggleButton));
    await tester.pumpAndSettle();

    expect(pageColor(tester), AppColors.light.background);
  });

  testWidgets('starts in dark mode when dark was saved', (tester) async {
    await pumpApp(tester, saved: {CacheConstants.themeMode: 'dark'});

    expect(pageColor(tester), AppColors.dark.background);
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
  });

  testWidgets('the choice is saved to the cache', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byType(ThemeToggleButton));
    await tester.pumpAndSettle();

    expect(CacheService.getData(key: CacheConstants.themeMode), 'dark');
  });

  testWidgets('two buttons stay in sync through the shared cubit', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await CacheService.cacheInitialization();
    getIt.registerLazySingleton<ThemeCubit>(ThemeCubit.new);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(children: const [ThemeToggleButton(), ThemeToggleButton()]),
        ),
      ),
    );

    await tester.tap(find.byType(ThemeToggleButton).first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode_outlined), findsNWidgets(2));
  });

  test('context.colors falls back to light without our theme', () {
    expect(AppColors.light.background, isNot(AppColors.dark.background));
    expect(
      AppColors.light.lerp(AppColors.dark, 1).surface,
      AppColors.dark.surface,
    );
  });

  testWidgets('context.colors falls back to light without our theme', (
    tester,
  ) async {
    late AppColors colors;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            colors = context.colors;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(colors.surface, AppColors.light.surface);
  });
}
