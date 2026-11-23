import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:worker_rest_calendar/features/home_widget/application/home_widget_service.dart';
import 'package:worker_rest_calendar/features/home_widget/domain/home_widget_snapshot.dart';

final class PluginHomeWidgetService implements HomeWidgetService {
  const PluginHomeWidgetService();

  static const snapshotKey = 'worker_rest_widget_snapshot_v1';
  static const providerName =
      'com.workerrestcalendar.app.WorkerRestHomeWidgetProvider';

  @override
  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Stream<Uri?> get widgetClicks => HomeWidget.widgetClicked;

  @override
  Future<Uri?> initiallyLaunchedUri() =>
      HomeWidget.initiallyLaunchedFromHomeWidget();

  @override
  Future<void> saveAndRefresh(HomeWidgetSnapshot snapshot) async {
    if (!isSupported) return;
    final saved = await HomeWidget.saveWidgetData<String>(
      snapshotKey,
      snapshot.toJsonString(),
    );
    if (saved == false) {
      throw StateError('Android 小组件快照保存失败');
    }
    final updated = await HomeWidget.updateWidget(
      qualifiedAndroidName: providerName,
    );
    if (updated == false) {
      throw StateError('Android 小组件刷新失败');
    }
  }
}
