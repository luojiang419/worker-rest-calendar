import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

final visualStyleProvider =
    NotifierProvider<VisualStyleController, AppVisualStyle>(
      VisualStyleController.new,
    );

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode value) {
    state = value;
  }
}

class VisualStyleController extends Notifier<AppVisualStyle> {
  @override
  AppVisualStyle build() => AppVisualStyle.classic;

  void setVisualStyle(AppVisualStyle value) {
    state = value;
  }
}
