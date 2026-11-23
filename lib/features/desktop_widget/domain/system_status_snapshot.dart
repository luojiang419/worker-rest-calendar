final class SystemStatusSnapshot {
  const SystemStatusSnapshot({
    required this.cpuUsage,
    required this.memoryUsage,
    this.batteryLevel,
    this.isCharging,
  });

  final double cpuUsage;
  final double memoryUsage;
  final int? batteryLevel;
  final bool? isCharging;
}
