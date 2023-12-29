import 'dart:io';

import 'package:calendar_events/calendar_permission_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'calendar_account_model.dart';
import 'calendar_event_model.dart';
import 'calendar_events_platform_interface.dart';

/// An implementation of [CalendarEventsPlatform] that uses method channels.
class MethodChannelCalendarEvents extends CalendarEventsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.godwin/calendar_events');

  @override
  Future<List<CalendarAccount>?> getCalendarAccounts() async {
    try {
      final list = await methodChannel
          .invokeMethod<List<dynamic>?>('getCalendarAccounts');
      if (list != null && list.isNotEmpty) {
        List<CalendarAccount> calendarList = <CalendarAccount>[];
        for (dynamic map in list) {
          var calendarId = map['calendarId'] as String;
          var accountName = map["accountName"] as String;
          var accountType = map["accountType"] as String;
          calendarList
              .add(CalendarAccount(calendarId, accountName, accountType));
        }
        return calendarList;
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  @override
  Future<bool> requestSync(CalendarAccount account) async {
    if (Platform.isIOS) return true;
    try {
      final map = {
        'accountName': account.accountName,
        'accountType': account.accountType,
      };
      final result = await methodChannel.invokeMethod<int>('requestSync', map);
      return result == 1;
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return false;
  }

  @override
  Future<int> requestPermission() async {
    try {
      final result = await methodChannel.invokeMethod<int>('requestPermission');
      return result ?? 0;
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return -1;
  }

  @override
  Future<CalendarPermission> checkCalendarPermission() async {
    try {
      final result = await methodChannel.invokeMethod<int>('checkPermission');
      return CalendarPermission.fromInt(result ?? 0);
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return CalendarPermission.noIdea;
  }

  @override
  Future<bool> addEvent(CalendarEvent event) async {
    try {
      final result =
          await methodChannel.invokeMethod<int>('addEvent', event.toJson());
      return result == 1;
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return false;
  }
}
