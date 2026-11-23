import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/app/app.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/desktop_window_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapDesktopWindow();
  runApp(const ProviderScope(child: WorkerRestCalendarApp()));
}
