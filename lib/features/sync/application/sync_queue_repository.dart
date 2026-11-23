import 'package:worker_rest_calendar/features/sync/domain/sync_queue_item.dart';

abstract interface class SyncQueueRepository {
  Future<void> enqueue(SyncQueueItem item);

  Future<List<SyncQueueItem>> getPending();

  Future<void> recordFailure(String id, String error);

  Future<void> remove(String id);
}
