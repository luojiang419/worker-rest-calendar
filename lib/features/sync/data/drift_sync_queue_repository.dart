import 'package:drift/drift.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/features/sync/application/sync_queue_repository.dart';
import 'package:worker_rest_calendar/features/sync/domain/sync_queue_item.dart';

final class DriftSyncQueueRepository implements SyncQueueRepository {
  const DriftSyncQueueRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> enqueue(SyncQueueItem item) => _database
      .into(_database.syncQueue)
      .insertOnConflictUpdate(
        SyncQueueCompanion.insert(
          id: item.id,
          entityType: item.entityType,
          entityId: item.entityId,
          operation: item.operation.name,
          payloadJson: item.payloadJson,
          createdAt: item.createdAt,
          attemptCount: Value(item.attemptCount),
          lastError: Value(item.lastError),
        ),
      );

  @override
  Future<List<SyncQueueItem>> getPending() async {
    final query = _database.select(_database.syncQueue)
      ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]);
    return (await query.get()).map(_fromRow).toList(growable: false);
  }

  @override
  Future<void> recordFailure(String id, String error) async {
    final row = await (_database.select(
      _database.syncQueue,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (row == null) {
      throw StateError('同步队列项不存在：$id');
    }
    await (_database.update(
      _database.syncQueue,
    )..where((table) => table.id.equals(id))).write(
      SyncQueueCompanion(
        attemptCount: Value(row.attemptCount + 1),
        lastError: Value(error),
      ),
    );
  }

  @override
  Future<void> remove(String id) => (_database.delete(
    _database.syncQueue,
  )..where((table) => table.id.equals(id))).go();

  SyncQueueItem _fromRow(SyncQueueRow row) => SyncQueueItem(
    id: row.id,
    entityType: row.entityType,
    entityId: row.entityId,
    operation: SyncOperation.values.byName(row.operation),
    payloadJson: row.payloadJson,
    createdAt: row.createdAt.toUtc(),
    attemptCount: row.attemptCount,
    lastError: row.lastError,
  );
}
