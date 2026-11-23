import 'package:go_router/go_router.dart';
import 'package:worker_rest_calendar/app/app_startup_page.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AppStartupPage()),
  ],
);
