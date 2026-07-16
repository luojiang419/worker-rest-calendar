import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/app/router/app_router.dart';
import 'package:worker_rest_calendar/core/date/current_date_lifecycle.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';
import 'package:worker_rest_calendar/core/theme/theme_controller.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_widget_display_mode.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/desktop_window_bootstrap.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

class WorkerRestCalendarApp extends ConsumerWidget {
  const WorkerRestCalendarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fallbackThemeMode = ref.watch(themeModeProvider);
    final fallbackVisualStyle = ref.watch(visualStyleProvider);
    final usesTransparentRoot =
        ref.watch(desktopWidgetPlatformProvider) &&
        ref.watch(desktopWidgetDisplayModeProvider) ==
            DesktopWidgetDisplayMode.widget;
    ref.listen(appPreferencesProvider, (previous, next) {
      next.whenData((preferences) {
        final mode = _themeMode(preferences.themeMode);
        if (ref.read(themeModeProvider) != mode) {
          ref.read(themeModeProvider.notifier).setThemeMode(mode);
        }
        if (ref.read(visualStyleProvider) != preferences.visualStyle) {
          ref
              .read(visualStyleProvider.notifier)
              .setVisualStyle(preferences.visualStyle);
        }
      });
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '工作日历',
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: appRouter,
      theme: AppTheme.lightFor(fallbackVisualStyle),
      darkTheme: AppTheme.darkFor(fallbackVisualStyle),
      themeMode: fallbackThemeMode,
      builder: (context, child) => CurrentDateLifecycle(
        child: AppThemeBackdrop(
          transparent: usesTransparentRoot,
          child: child!,
        ),
      ),
    );
  }

  ThemeMode _themeMode(AppThemePreference preference) => switch (preference) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
}

class AppThemeBackdrop extends StatelessWidget {
  const AppThemeBackdrop({
    required this.child,
    this.transparent = false,
    super.key,
  });

  final Widget child;
  final bool transparent;

  @override
  Widget build(BuildContext context) {
    if (transparent) {
      return ColoredBox(
        key: const ValueKey('app-theme-backdrop-transparent'),
        color: Colors.transparent,
        child: child,
      );
    }
    final tokens = context.tokens;
    if (tokens.visualStyle != AppVisualStyle.glass) {
      return ColoredBox(color: tokens.colors.background, child: child);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tokens.colors.background,
            tokens.backgroundAccent,
            tokens.colors.background,
          ],
          stops: const [0, 0.48, 1],
        ),
      ),
      child: child,
    );
  }
}
