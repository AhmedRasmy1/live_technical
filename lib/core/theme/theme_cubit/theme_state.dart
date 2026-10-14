part of 'theme_cubit.dart';

/// Every state carries the active [themeMode] so `MaterialApp` always has one.
@immutable
sealed class ThemeState {
  const ThemeState(this.themeMode);

  final ThemeMode themeMode;
}

/// Mode restored from the cache at startup.
final class ThemeInitial extends ThemeState {
  const ThemeInitial(super.themeMode);
}

/// Mode after the user toggled it.
final class ThemeSuccess extends ThemeState {
  const ThemeSuccess(super.themeMode);
}
