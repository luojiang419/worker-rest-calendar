final class SelectedBackupFile {
  const SelectedBackupFile({required this.name, required this.contents});

  final String name;
  final String contents;
}

abstract interface class BackupFileGateway {
  Future<String?> saveJson({
    required String suggestedName,
    required String json,
  });

  Future<SelectedBackupFile?> openJson();
}
