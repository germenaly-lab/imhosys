import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/local_persistence_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _initTheme();
  }

  Future<void> _initTheme() async {
    final savedMode = await LocalPersistenceService.loadThemeMode();
    emit(savedMode);
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(newMode);
    LocalPersistenceService.saveThemeMode(newMode);
  }

  void setThemeMode(ThemeMode mode) {
    emit(mode);
    LocalPersistenceService.saveThemeMode(mode);
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
