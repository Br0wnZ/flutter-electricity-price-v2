import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _prefKey = 'theme_mode';
  final SharedPreferences _prefs;
  ThemeCubit(this._prefs, ThemeMode initial) : super(initial);

  static ThemeMode parse(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String stringify(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  void setMode(ThemeMode mode) {
    if (state == mode) return;
    _prefs.setString(_prefKey, stringify(mode));
    emit(mode);
  }
}
