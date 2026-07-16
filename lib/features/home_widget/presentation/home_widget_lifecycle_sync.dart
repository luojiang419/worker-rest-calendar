import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/features/home_widget/application/home_widget_sync_controller.dart';

class HomeWidgetLifecycleSync extends ConsumerStatefulWidget {
  const HomeWidgetLifecycleSync({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<HomeWidgetLifecycleSync> createState() =>
      _HomeWidgetLifecycleSyncState();
}

class _HomeWidgetLifecycleSyncState
    extends ConsumerState<HomeWidgetLifecycleSync>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(homeWidgetSyncControllerProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(homeWidgetSyncControllerProvider);
    return widget.child;
  }
}
