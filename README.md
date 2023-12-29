# calendar_events

A simple plugin for flutter to play with calendar events. You can easily fetch calendar accounts and add events.

## Installation

In your `pubspec.yaml` file within your Flutter Project:

```yaml
dependencies:
  calendar_events: ^1.0.0
```
### Android integration

The plugin doesn't need any special permissions by default to add events to the calendar. However, events can also be added without launching the calendar application, for this it is needed to add calendar permissions to your `AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.WRITE_CALENDAR" />
<uses-permission android:name="android.permission.READ_CALENDAR" />
```

### iOS integration

In order to make this plugin work on iOS 10+, be sure to add this to your `info.plist` file:

```xml
<key>NSCalendarsFullAccessUsageDescription</key>
<string>We need access to your calendars to provide awesome features.</string>
<key>NSCalendarsWriteOnlyAccessUsageDescription</key>
<string>We need access to your calendars to provide awesome features.</string>
<key>NSCalendarsUsageDescription</key>
<string>We need access to your calendars to provide awesome features.</string>
```

## Use it
```dart
import 'package:calendar_events/calendar_events.dart';

final _calenderEventsPlugin = CalendarEvents();

/// Now you can request permission in iOS platform only. But you can request permission using any other plugin.
_requestPermission() async {
  if (Platform.isIOS) {
    _calenderEventsPlugin.requestPermission();
    return;
  }
  if (!(await Permission.calendarFullAccess.isGranted)) {
    if (await Permission.calendarFullAccess
        .request()
        .isGranted) {
      _checkPermission();
    }
  }
}

/// You can check permission using this function.This function will return Permission enum.
/// IN Android it only return either allowed or denied
_checkPermission() async {
  CalendarPermission? permission = await _calenderEventsPlugin.checkCalendarPermission();
}

/// You can list the available calendar accounts. You can get the calendarId, accountName and accountType from this method.
_listAccounts() async {
  accounts = await _calenderEventsPlugin.getCalendarAccounts();
}

///You can use the CalendarEvent class to create an event. 
void _addEvent(CalendarAccount account) async {
  final event = CalendarEvent(
      calendarId: account.calenderId,
      title: 'Sample Event',
      location: 'Location',
      description: 'desc',
      start: DateTime.now().add(const Duration(hours: 1)),
      end: DateTime.now().add(const Duration(hours: 2)),
      recurrence:
      EventRecurrence(frequency: EventFrequency.daily, interval: 2));

  var bool = await _calenderEventsPlugin.addEvent(event);
}

/// This function will request sync. This will only work in Android, In iOS it will blindly return true.
/// Or you can pass accountName and accountType to CalendarEvent, it will automatically requestSync without this function.
_requestSync(CalendarAccount account) async{
  bool = await _calenderEventsPlugin.requestSync(account);
}
```

### Plugin Classes

#### 1. CalendarAccount
```dart
class CalendarAccount {
  final String calenderId;
  final String accountName;
  final String accountType;
}
```
#### 2. CalendarEvent

```dart
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
}
```
#### 3. EventFrequency

```dart
enum EventFrequency {
  /*not available on iOS: secondly, minutely, hourly, */
  daily,
  weekly,
  monthly,
  yearly
}
```
#### 4. EventRecurrence 
```dart
class EventRecurrence {
  /// The frequency of the recurrence rule.
  final EventFrequency? frequency;

  /// Indicates the number of occurrences until the rule ends.
  final int? occurrences;

  /// Indicates when the recurrence rule ends.
  final DateTime? endDate;

  /// Specifies how often the recurrence rule repeats over the unit of time indicated by its frequency.
  final int interval;

  /// (Android only) If you have a specific rule that cannot be matched with current parameters, you can specify a RRULE in RFC5545 format
  final String? rRule;
}
```