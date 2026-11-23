import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_window_placement.dart';

typedef DesktopWindowLegacyPlacementMigrator =
    DesktopWindowPlacement? Function(
      String displayId,
      DesktopWindowPosition legacyPosition,
    );

final class StoredDesktopWindowPlacement {
  const StoredDesktopWindowPlacement({
    required this.displayId,
    required this.placement,
  });

  final String displayId;
  final DesktopWindowPlacement placement;
}

final class DesktopWindowPositionStore {
  const DesktopWindowPositionStore();

  static const _positionsKeyV1 = 'desktop_widget_positions_v1';
  static const _lastDisplayKeyV1 = 'desktop_widget_last_display_v1';
  static const _placementsKeyV2 = 'desktop_widget_placements_v2';
  static const _lastDisplayKeyV2 = 'desktop_widget_last_display_v2';

  Future<void> savePlacement(
    String displayId,
    DesktopWindowPlacement placement,
  ) async {
    _validatePlacement(placement);
    final preferences = await SharedPreferences.getInstance();
    await _writePlacement(
      preferences: preferences,
      displayId: displayId,
      placement: placement,
      markLast: true,
    );
  }

  Future<DesktopWindowPlacement?> loadPlacement(
    String displayId, {
    required DesktopWindowLegacyPlacementMigrator migrateLegacy,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    return _loadPlacement(
      preferences: preferences,
      displayId: displayId,
      migrateLegacy: migrateLegacy,
      markLastAfterMigration: false,
    );
  }

  Future<StoredDesktopWindowPlacement?> loadLastPlacement({
    required DesktopWindowLegacyPlacementMigrator migrateLegacy,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final candidateDisplayIds = <String>{
      ?preferences.getString(_lastDisplayKeyV2),
      ?preferences.getString(_lastDisplayKeyV1),
    };
    for (final displayId in candidateDisplayIds) {
      final placement = await _loadPlacement(
        preferences: preferences,
        displayId: displayId,
        migrateLegacy: migrateLegacy,
        markLastAfterMigration: true,
      );
      if (placement == null) continue;
      if (preferences.getString(_lastDisplayKeyV2) != displayId) {
        await preferences.setString(_lastDisplayKeyV2, displayId);
      }
      return StoredDesktopWindowPlacement(
        displayId: displayId,
        placement: placement,
      );
    }
    return null;
  }

  Future<DesktopWindowPlacement?> _loadPlacement({
    required SharedPreferences preferences,
    required String displayId,
    required DesktopWindowLegacyPlacementMigrator migrateLegacy,
    required bool markLastAfterMigration,
  }) async {
    final placements = _decodeMap(preferences.getString(_placementsKeyV2));
    final placement = _decodePlacement(placements[displayId]);
    if (placement != null) return placement;

    final legacyPositions = _decodeMap(preferences.getString(_positionsKeyV1));
    final legacyPosition = _decodeLegacyPosition(legacyPositions[displayId]);
    if (legacyPosition == null) return null;
    final migrated = migrateLegacy(displayId, legacyPosition);
    if (migrated == null) return null;
    _validatePlacement(migrated);
    await _writePlacement(
      preferences: preferences,
      displayId: displayId,
      placement: migrated,
      markLast: markLastAfterMigration,
    );
    return migrated;
  }

  Future<void> _writePlacement({
    required SharedPreferences preferences,
    required String displayId,
    required DesktopWindowPlacement placement,
    required bool markLast,
  }) async {
    final placements = _decodeMap(preferences.getString(_placementsKeyV2));
    placements[displayId] = _encodePlacement(placement);
    await preferences.setString(_placementsKeyV2, jsonEncode(placements));
    if (markLast) {
      await preferences.setString(_lastDisplayKeyV2, displayId);
    }
  }

  Map<String, Object?> _encodePlacement(DesktopWindowPlacement placement) =>
      <String, Object?>{
        'schemaVersion': 2,
        'horizontal': _encodeAxis(placement.horizontal),
        'vertical': _encodeAxis(placement.vertical),
      };

  Map<String, Object?> _encodeAxis(DesktopWindowAxisPlacement axis) =>
      <String, Object?>{'anchor': axis.anchor.name, 'value': axis.value};

  DesktopWindowPlacement? _decodePlacement(Object? source) {
    final map = _asMap(source);
    if (map == null || map['schemaVersion'] != 2) return null;
    final horizontal = _decodeAxis(map['horizontal']);
    final vertical = _decodeAxis(map['vertical']);
    if (horizontal == null || vertical == null) return null;
    return DesktopWindowPlacement(horizontal: horizontal, vertical: vertical);
  }

  DesktopWindowAxisPlacement? _decodeAxis(Object? source) {
    final map = _asMap(source);
    if (map == null) return null;
    final anchor = switch (map['anchor']) {
      'startEdge' => DesktopWindowAnchor.startEdge,
      'proportional' => DesktopWindowAnchor.proportional,
      'endEdge' => DesktopWindowAnchor.endEdge,
      _ => null,
    };
    final rawValue = map['value'];
    if (anchor == null || rawValue is! num) return null;
    final axis = DesktopWindowAxisPlacement(
      anchor: anchor,
      value: rawValue.toDouble(),
    );
    return _isValidAxis(axis) ? axis : null;
  }

  DesktopWindowPosition? _decodeLegacyPosition(Object? source) {
    final map = _asMap(source);
    if (map == null) return null;
    final dx = map['dx'];
    final dy = map['dy'];
    if (dx is! num || dy is! num) return null;
    final x = dx.toDouble();
    final y = dy.toDouble();
    if (!x.isFinite || !y.isFinite) return null;
    return DesktopWindowPosition(x, y);
  }

  void _validatePlacement(DesktopWindowPlacement placement) {
    if (!_isValidAxis(placement.horizontal) ||
        !_isValidAxis(placement.vertical)) {
      throw ArgumentError.value(placement, 'placement', '定位锚点或数值无效');
    }
  }

  bool _isValidAxis(DesktopWindowAxisPlacement axis) {
    if (!axis.value.isFinite || axis.value < 0) return false;
    return axis.anchor != DesktopWindowAnchor.proportional || axis.value <= 1;
  }

  Map<String, Object?> _decodeMap(String? source) {
    if (source == null) return <String, Object?>{};
    try {
      return _asMap(jsonDecode(source)) ?? <String, Object?>{};
    } on FormatException {
      return <String, Object?>{};
    }
  }

  Map<String, Object?>? _asMap(Object? source) {
    if (source is! Map) return null;
    final result = <String, Object?>{};
    for (final entry in source.entries) {
      if (entry.key is! String) return null;
      result[entry.key as String] = entry.value;
    }
    return result;
  }
}
