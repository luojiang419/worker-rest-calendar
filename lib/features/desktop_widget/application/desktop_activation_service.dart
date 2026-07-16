import 'package:worker_rest_calendar/core/date/calendar_date.dart';

typedef DesktopActivationHandler =
    Future<void> Function(DesktopActivationIntent intent);

final class DesktopActivationIntent {
  DesktopActivationIntent({required List<String> arguments})
    : arguments = List.unmodifiable(arguments),
      selectedDate = _selectedDate(arguments);

  final List<String> arguments;
  final CalendarDate? selectedDate;

  static CalendarDate? _selectedDate(List<String> arguments) {
    final pattern = RegExp(r'restcalendar://date/(\d{4}-\d{2}-\d{2})');
    for (final argument in arguments) {
      final match = pattern.firstMatch(argument);
      if (match == null) continue;
      try {
        return CalendarDate.parse(match.group(1)!);
      } on ArgumentError {
        continue;
      } on FormatException {
        continue;
      }
    }
    return null;
  }
}

abstract interface class DesktopActivationService {
  Future<List<DesktopActivationIntent>> initialize();

  Future<void> startListening(DesktopActivationHandler handler);

  Future<void> dispose();
}
