import 'package:worker_rest_calendar/features/updater/domain/update_models.dart';

abstract interface class UpdateSettingsRepository {
  Future<UpdateSettings> load();

  Future<void> save(UpdateSettings settings);
}
