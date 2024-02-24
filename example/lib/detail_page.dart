import 'dart:io';

import 'package:calendar_events/calendar_events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  final CalendarAccount calendarAccount;

  const DetailPage({super.key, required this.calendarAccount});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  CalendarAccount get account => widget.calendarAccount;
  String? eventId;
  final _calenderEventsPlugin = CalendarEvents();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Add event')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text('You are going to add to this calendar account'),
                const SizedBox(
                  height: 20,
                ),
                if (Platform.isAndroid)
                  Text(
                      '1. CalendarId: ${widget.calendarAccount.calenderId}\n2. accountName: ${account.accountName}\n3.Type: ${account.accountType}\n4.DisplayName: ${account.androidAccountParams!.displayName}\n5.Name: ${account.androidAccountParams!.name}\n6.Owner: ${account.androidAccountParams!.ownerAccount}\n7.Primary: ${account.androidAccountParams!.isPrimary}'),
                if (Platform.isIOS)
                  Text(
                      '1. CalendarId: ${account.calenderId}\n2. accountName: ${account.accountName}\n3.Type: ${account.accountType}\n4.SourceId: ${account.iosAccountParams!.sourceId}\n5.SourceType: ${account.iosAccountParams!.sourceType}\n6.SourceTitle: ${account.iosAccountParams!.sourceTitle}'),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      _addEvent(account);
                    },
                    child: const Text('Add event')),
                const SizedBox(
                  height: 20,
                ),
                if (eventId != null)
                  ElevatedButton(
                      onPressed: () {
                        _updateEvent(account);
                      },
                      child: const Text('Update event')),
                const SizedBox(
                  height: 20,
                ),
                if (eventId != null)
                  ElevatedButton(
                      onPressed: () {
                        _deleteEvent(account);
                      },
                      child: const Text('Delete event'))
              ],
            ),
          ),
        ),
      ),
    );
  }

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

    eventId = await _calenderEventsPlugin.addEvent(event);

    var showSnackBar = scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text(
            'Calender added ${eventId != null ? 'success($eventId)' : 'failed'}')));

    var bool = await _calenderEventsPlugin.requestSync(account);
    setState(() {});
    if (kDebugMode) {
      print('Syncing : $bool');
    }
  }

  void _updateEvent(CalendarAccount account) async {
    final event = CalendarEvent(
        eventId: eventId,
        calendarId: account.calenderId,
        title: 'Update Sample Event',
        location: 'Location',
        description: 'desc',
        start: DateTime.now().add(const Duration(hours: 1)),
        end: DateTime.now().add(const Duration(hours: 2)),
        recurrence:
            EventRecurrence(frequency: EventFrequency.daily, interval: 2));

    eventId = await _calenderEventsPlugin.updateEvent(event);

    var showSnackBar = scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text(
            'Calender added ${eventId != null ? 'success($eventId)' : 'failed'}')));

    var bool = await _calenderEventsPlugin.requestSync(account);
    setState(() {});
    if (kDebugMode) {
      print('Syncing : $bool');
    }
  }

  void _deleteEvent(CalendarAccount account) async {
    final event = CalendarEvent(
        eventId: eventId,
        calendarId: account.calenderId,
        title: 'Update Sample Event',
        location: 'Location',
        description: 'desc',
        start: DateTime.now().add(const Duration(hours: 1)),
        end: DateTime.now().add(const Duration(hours: 2)),
        recurrence:
            EventRecurrence(frequency: EventFrequency.daily, interval: 2));

    eventId = await _calenderEventsPlugin.deleteEvent(event);

    var showSnackBar = scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text(
            'Calender deleted ${eventId != null ? 'success($eventId)' : 'failed'}')));
    eventId = null;
    setState(() {});
  }
}
