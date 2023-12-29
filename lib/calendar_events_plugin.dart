import 'package:calendar_events/calendar_permission_result.dart';

import 'calendar_account_model.dart';
import 'calendar_event_model.dart';
import 'calendar_events_platform_interface.dart';

class CalendarEvents {
  Future<List<CalendarAccount>?> getCalendarAccounts() {
    return CalendarEventsPlatform.instance.getCalendarAccounts();
  }

  Future<bool> requestSync(CalendarAccount account) {
    return CalendarEventsPlatform.instance.requestSync(account);
  }

  Future<int> requestPermission() {
    return CalendarEventsPlatform.instance.requestPermission();
  }

  Future<bool> addEvent(CalendarEvent event) {
    return CalendarEventsPlatform.instance.addEvent(event);
  }

  Future<CalendarPermission> checkCalendarPermission() {
    return CalendarEventsPlatform.instance.checkCalendarPermission();
  }
}
