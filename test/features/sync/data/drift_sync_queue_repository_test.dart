import 'package:drift/native.dart';
import 'package:test/test.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/features/sync/data/drift_sync_queue_repository.dart';
import 'package:worker_rest_calendar/features/sync/domain/sync_queue_item.dart';

void main() {
  test('同步队列支持入队、失败计数和移除', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftSyncQueueRepository(database);
    final item = SyncQueueItem(
      id: 'queue-1',
      entityType: 'scheduleProfile',
      entityId: 'profile-1',
      operation: SyncOperation.upsert,
      payloadJson: '{}',
      createdAt: DateTime.utc(2026, 7, 12),
    );

    await repository.enqueue(item);
    await repository.recordFailure('queue-1', 'offline');

    final failed = (await repository.getPending()).single;
    expect(failed.attemptCount, 1);
    expect(failed.lastError, 'offline');

    await repository.remove('queue-1');
    expect(await repository.getPending(), isEmpty);
  });
}
