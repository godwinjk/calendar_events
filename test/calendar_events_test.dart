import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:calendar_events/calendar_events_platform_interface.dart';
import 'package:calendar_events/calendar_events_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCalendarEventsPlatform
    with MockPlatformInterfaceMixin
    implements CalendarEventsPlatform {
  @override
  Future<CalendarPermission> checkCalendarPermission() {
    // TODO: implement checkCalendarPermission
    throw UnimplementedError();
  }

  @override
  Future<List<CalendarAccount>?> getCalendarAccounts() {
    // TODO: implement getCalendarAccounts
    throw UnimplementedError();
  }

  @override
  Future<bool> requestSync(CalendarAccount account) {
    // TODO: implement requestSync
    throw UnimplementedError();
  }

  @override
  Future<int> requestPermission() {
    // TODO: implement requestPermission
    throw UnimplementedError();
  }

  @override
  Future<String?> addEvent(CalendarEvent event) {
    // TODO: implement addEvent
    throw UnimplementedError();
  }

  @override
  Future<String?> deleteEvent(CalendarEvent event) {
    // TODO: implement deleteEvent
    throw UnimplementedError();
  }

  @override
  Future<String?> updateEvent(CalendarEvent event) {
    // TODO: implement updateEvent
    throw UnimplementedError();
  }

  @override
  Future<String?> deleteEventWithId(String eventId) {
    // TODO: implement deleteEventWithId
    throw UnimplementedError();
  }
}

void main() {
  final CalendarEventsPlatform initialPlatform =
      CalendarEventsPlatform.instance;

  test('$MethodChannelCalendarEvents is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCalendarEvents>());
  });
}
