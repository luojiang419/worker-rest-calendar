import 'package:worker_rest_calendar/features/desktop_widget/domain/system_status_snapshot.dart';

abstract interface class SystemStatusService {
  bool get isSupported;

  Future<SystemStatusSnapshot?> read();
}
