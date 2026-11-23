import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/core/date/current_date_controller.dart';

class CurrentDateLifecycle extends ConsumerStatefulWidget {
  const CurrentDateLifecycle({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<CurrentDateLifecycle> createState() =>
      _CurrentDateLifecycleState();
}

class _CurrentDateLifecycleState extends ConsumerState<CurrentDateLifecycle>
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
      ref.read(todayProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(todayProvider);
    return widget.child;
  }
}
