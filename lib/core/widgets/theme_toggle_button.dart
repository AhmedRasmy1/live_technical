import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../di/di.dart';
import '../extensions/theme_helper.dart';
import '../resources/app_constants.dart';
import '../theme/theme_cubit/theme_cubit.dart';

/// Switches between light and dark mode.
/// Shows the moon while the app is light and the sun while it is dark,
/// i.e. the mode you will get when you tap it.
class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({super.key});

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton> {
  // Shared app-wide cubit: do not close it here.
  late ThemeCubit themeCubit;

  @override
  void initState() {
    themeCubit = getIt.get<ThemeCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      bloc: themeCubit,
      builder: (context, state) {
        final isDark = state.themeMode == ThemeMode.dark;
        return IconButton(
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          iconSize: AppConstants.iconSize,
          color: context.colors.textPrimary,
          onPressed: themeCubit.toggleTheme,
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
        );
      },
    );
  }
}
