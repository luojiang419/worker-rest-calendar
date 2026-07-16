import 'package:worker_rest_calendar/features/home_widget/domain/home_widget_snapshot.dart';

abstract interface class HomeWidgetService {
  bool get isSupported;

  Stream<Uri?> get widgetClicks;

  Future<Uri?> initiallyLaunchedUri();

  Future<void> saveAndRefresh(HomeWidgetSnapshot snapshot);
}
