typedef DesktopDisplayConfigurationHandler = Future<void> Function();

abstract interface class DesktopDisplayConfigurationService {
  Future<void> initialize(DesktopDisplayConfigurationHandler handler);

  Future<void> dispose();
}
