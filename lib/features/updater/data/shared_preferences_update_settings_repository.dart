import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker_rest_calendar/features/updater/application/update_settings_repository.dart';
import 'package:worker_rest_calendar/features/updater/domain/semantic_version.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_models.dart';

final class SharedPreferencesUpdateSettingsRepository
    implements UpdateSettingsRepository {
  const SharedPreferencesUpdateSettingsRepository(this._preferences);

  static const _policyKey = 'updater.policy';
  static const _networkModeKey = 'updater.networkMode';
  static const _manualProxyKey = 'updater.manualProxyUrl';
  static const _pendingKey = 'updater.pending';
  static const _deferredVersionKey = 'updater.deferredVersion';

  final SharedPreferences _preferences;

  @override
  Future<UpdateSettings> load() async {
    final pendingJson = _preferences.getString(_pendingKey);
    final deferred = _preferences.getString(_deferredVersionKey);
    return UpdateSettings(
      policy: _enumByName(
        UpdatePolicy.values,
        _preferences.getString(_policyKey),
        UpdatePolicy.automatic,
      ),
      networkMode: _enumByName(
        UpdateNetworkMode.values,
        _preferences.getString(_networkModeKey),
        UpdateNetworkMode.automaticProxy,
      ),
      manualProxyUrl:
          _preferences.getString(_manualProxyKey) ?? 'http://127.0.0.1:7890',
      pending: pendingJson == null
          ? null
          : PendingUpdate.fromJson(
              jsonDecode(pendingJson) as Map<String, Object?>,
            ),
      deferredVersion: deferred == null
          ? null
          : SemanticVersion.parse(deferred),
    );
  }

  @override
  Future<void> save(UpdateSettings settings) async {
    await Future.wait([
      _preferences.setString(_policyKey, settings.policy.name),
      _preferences.setString(_networkModeKey, settings.networkMode.name),
      _preferences.setString(_manualProxyKey, settings.manualProxyUrl),
      if (settings.pending == null)
        _preferences.remove(_pendingKey)
      else
        _preferences.setString(
          _pendingKey,
          jsonEncode(settings.pending!.toJson()),
        ),
      if (settings.deferredVersion == null)
        _preferences.remove(_deferredVersionKey)
      else
        _preferences.setString(
          _deferredVersionKey,
          settings.deferredVersion.toString(),
        ),
    ]);
  }
}

T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  if (name == null) return fallback;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
