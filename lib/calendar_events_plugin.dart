import 'package:calendar_events/calendar_permission_result.dart';

import 'calendar_account_model.dart';
import 'calendar_event_model.dart';
import 'calendar_events_platform_interface.dart';

class CalendarEvents {
  ///This call check the permission for this action to proceed. You should
  ///explicitly call this before invoking any call to this plugin.
  Future<CalendarPermission> checkCalendarPermission() {
    return CalendarEventsPlatform.instance.checkCalendarPermission();
  }

  ///This method will fetch the calendar accounts associated to this device. If you are added
  ///any external calendars make sure it is synced and available using any calendar applications.
  Future<List<CalendarAccount>?> getCalendarAccounts() {
    return CalendarEventsPlatform.instance.getCalendarAccounts();
  }

  ///This is particular for android for syncing. This call immediately sync the entries you have added to the calendar.
  ///Otherwise it might not sync or take delays to sync.
  Future<bool> requestSync(CalendarAccount account) {
    return CalendarEventsPlatform.instance.requestSync(account);
  }

  ///This will request the permission for particular devices. Including runtime permission in android. Make sure you have added
  ///permissions in both manifest and info.plist
  Future<int> requestPermission() {
    return CalendarEventsPlatform.instance.requestPermission();
  }

  ///For adding events to the native calendar
  ///Please check [checkCalendarPermission] and [requestPermission]
  Future<String?> addEvent(CalendarEvent event) {
    return CalendarEventsPlatform.instance.addEvent(event);
  }

  ///For updating events to the native calendar.
  ///Please check [checkCalendarPermission] and [requestPermission]
  Future<String?> updateEvent(CalendarEvent event) {
    return CalendarEventsPlatform.instance.updateEvent(event);
  }

  ///For deleting events to the native calendar
  ///Please check [checkCalendarPermission] and [requestPermission]
  Future<String?> deleteEvent(CalendarEvent event) {
    return CalendarEventsPlatform.instance.deleteEvent(event);
  }
}
