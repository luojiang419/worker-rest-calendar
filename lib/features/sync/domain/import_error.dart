sealed class ImportException implements Exception {
  const ImportException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class ImportSchemaMismatch extends ImportException {
  const ImportSchemaMismatch({required String actual, required String expected})
    : super('导入版本 $actual 与当前版本 $expected 不兼容');
}

final class InvalidImportData extends ImportException {
  const InvalidImportData(super.message);
}

final class ImportFileTooLarge extends ImportException {
  const ImportFileTooLarge({required int actualBytes, required int maxBytes})
    : super('导入数据大小 $actualBytes 字节，超过上限 $maxBytes 字节');
}
