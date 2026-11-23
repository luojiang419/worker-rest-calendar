import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_window_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/system_status_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/weather_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_todo_item.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/system_status_snapshot.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/weather_snapshot.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_countdown_card.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_moon_card.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_system_status_card.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_todo_card.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_weather_card.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('五种信息摆件在小中大尺寸与 130% 字体下无溢出', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    for (final size in DesktopWidgetSize.values) {
      final dimensions = desktopWidgetWindowSize(size);
      tester.view.physicalSize = dimensions;
      for (final card in _cards(size)) {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(
              size: dimensions,
              textScaler: const TextScaler.linear(1.3),
            ),
            child: MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(body: card),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          tester.takeException(),
          isNull,
          reason: '${size.name} ${card.runtimeType}',
        );
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

List<Widget> _cards(DesktopWidgetSize size) => [
  DesktopCountdownCard(
    title: '项目正式上线',
    isoDate: '2026-08-01',
    size: size,
    positionLocked: false,
    onStartDragging: () {},
    onChanged: (_, _) {},
    now: () => DateTime(2026, 7, 16),
  ),
  DesktopTodoCard(
    items: const [
      DesktopTodoItem(id: '1', title: '完成全部自动化测试'),
      DesktopTodoItem(id: '2', title: '核对发布说明', completed: true),
    ],
    size: size,
    positionLocked: false,
    onStartDragging: () {},
    onChanged: (_) {},
  ),
  DesktopMoonCard(size: size, now: () => DateTime(2026, 7, 16)),
  DesktopSystemStatusCard(size: size, service: const _SystemStatusService()),
  DesktopWeatherCard(city: '北京', size: size, service: const _WeatherService()),
];

final class _SystemStatusService implements SystemStatusService {
  const _SystemStatusService();

  @override
  bool get isSupported => true;

  @override
  Future<SystemStatusSnapshot?> read() async => const SystemStatusSnapshot(
    cpuUsage: 42,
    memoryUsage: 68,
    batteryLevel: 86,
    isCharging: false,
  );
}

final class _WeatherService implements WeatherService {
  const _WeatherService();

  @override
  Future<WeatherSnapshot> fetch(
    String city, {
    bool forceRefresh = false,
  }) async => WeatherSnapshot(
    city: city,
    temperature: 30,
    apparentTemperature: 33,
    weatherCode: 2,
    windSpeed: 8,
    humidity: 60,
    fetchedAt: DateTime(2026, 7, 16),
  );
}
