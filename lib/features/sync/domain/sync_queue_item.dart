enum SyncOperation { upsert, delete }

final class SyncQueueItem {
  const SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
    required this.createdAt,
    this.attemptCount = 0,
    this.lastError,
  });

  final String id;
  final String entityType;
  final String entityId;
  final SyncOperation operation;
  final String payloadJson;
  final DateTime createdAt;
  final int attemptCount;
  final String? lastError;
}
