import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'calendar_account_model.dart';
import 'calendar_event_model.dart';
import 'calendar_events_method_channel.dart';
import 'calendar_permission_result.dart';

abstract class CalendarEventsPlatform extends PlatformInterface {
  /// Constructs a CalenderEventsPlatform.
  CalendarEventsPlatform() : super(token: _token);

  static final Object _token = Object();

  static CalendarEventsPlatform _instance = MethodChannelCalendarEvents();

  /// The default instance of [CalendarEventsPlatform] to use.
  ///
  /// Defaults to [MethodChannelCalendarEvents].
  static CalendarEventsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CalendarEventsPlatform] when
  /// they register themselves.
  static set instance(CalendarEventsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<CalendarAccount>?> getCalendarAccounts() {
    throw UnimplementedError('getCalendarAccounts() has not been implemented.');
  }

  Future<bool> requestSync(CalendarAccount account) {
    throw UnimplementedError(
        'requestSync(CalendarAccount) has not been implemented.');
  }

  Future<int> requestPermission() {
    throw UnimplementedError('requestPermission() has not been implemented.');
  }

  Future<String?> addEvent(CalendarEvent event) {
    throw UnimplementedError(
        'requestSync(CalendarAccount) has not been implemented.');
  }

  Future<String?> updateEvent(CalendarEvent event) {
    throw UnimplementedError(
        'requestSync(CalendarAccount) has not been implemented.');
  }

  Future<String?> deleteEvent(CalendarEvent event) {
    throw UnimplementedError(
        'requestSync(CalendarAccount) has not been implemented.');
  }

  Future<String?> deleteEventWithId(String eventId) {
    throw UnimplementedError(
        'requestSync(CalendarAccount) has not been implemented.');
  }

  Future<CalendarPermission> checkCalendarPermission() {
    throw UnimplementedError(
        'requestSync(CalendarAccount) has not been implemented.');
  }
}
