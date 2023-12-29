import 'dart:io';

import 'calendar_params.dart';
import 'calendar_recurrence.dart';
import 'calendar_reminder_type.dart';

class CalendarEvent {
  final String calendarId;
  final String title;
  final String description;
  final String location;
  final DateTime start;
  final DateTime end;
  final String? timeZone;
  final int? allDay;

  final EventRecurrence? recurrence;
  final AndroidParams? androidParams;
  final IosParams? iosParams;

  CalendarEvent(
      {required this.calendarId,
      required this.title,
      required this.description,
      required this.location,
      required this.start,
      required this.end,
      this.timeZone,
      this.allDay,
      this.recurrence,
      this.androidParams,
      this.iosParams});

  Map<String, dynamic> toJson() {
    final params = {
      'title': title,
      'description': description,
      'location': location,
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
      'timeZone': timeZone,
      'allDay': allDay,
      'recurrence': recurrence?.toJson(),
    };

    if (Platform.isIOS) {
      if (iosParams != null) {
        params['reminderSeconds'] = (iosParams?.reminder?.inSeconds ?? 0);
        params['url'] = iosParams?.url;
      }
      params['calendarId'] = calendarId;
    }
    if (Platform.isAndroid) {
      if (androidParams != null) {
        params['reminderMinutes'] = androidParams?.reminderMinutes;
        params['reminderTypes'] = androidParams?.reminderType;
        params['emailInvites'] =
            androidParams?.emailInvites?.map((e) => e.toJson()).toList();
      }
      params['calendarId'] = int.tryParse(calendarId);
    }
    return params;
  }
}
