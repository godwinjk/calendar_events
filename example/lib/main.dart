import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:calendar_events/calendar_events.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _calenderEventsPlugin = CalendarEvents();
  CalendarPermission? havePermission;
  List<CalendarAccount>? accounts;
  int? selectedCalenderId;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (havePermission == null ||
                    havePermission != CalendarPermission.allowed)
                  ElevatedButton(
                      onPressed: () {
                        _requestPermission();
                      },
                      child: const Text('Request permission')),
                ElevatedButton(
                    onPressed: () {
                      _checkPermission();
                    },
                    child: Text(havePermission == null
                        ? 'Check Permission'
                        : 'You have ${havePermission == null ? "no " : ''} calender permission : $havePermission')),
                if (havePermission != null &&
                    havePermission == CalendarPermission.allowed)
                  ElevatedButton(
                      onPressed: () {
                        _listAccounts();
                      },
                      child: Text(accounts == null
                          ? 'Get accounts'
                          : 'You have got calender accounts')),
                if (accounts != null)
                  for (CalendarAccount account in accounts!)
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            _showDialog(account);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            child: Builder(builder: (context) {
                              if (Platform.isAndroid) {
                                return Text(
                                    '1. CalendarId: ${account.calenderId}\n2. accountName: ${account.accountName}\n3.Type: ${account.accountType}\n4.DisplayName: ${account.androidAccountParams!.displayName}\n5.Name: ${account.androidAccountParams!.name}\n6.Owner: ${account.androidAccountParams!.ownerAccount}\n7.Primary: ${account.androidAccountParams!.isPrimary}');
                              }
                              if (Platform.isIOS) {
                                return Text(
                                    '1. CalendarId: ${account.calenderId}\n2. accountName: ${account.accountName}\n3.Type: ${account.accountType}\n4.SourceId: ${account.iosAccountParams!.sourceId}\n5.SourceType: ${account.iosAccountParams!.sourceType}\n6.SourceTitle: ${account.iosAccountParams!.sourceTitle}}');
                              }
                              return Container();
                            }),
                          ),
                        ),
                        const Divider(
                          height: 2,
                          thickness: 2,
                        )
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _requestPermission() async {
    _calenderEventsPlugin.requestPermission();
    /* if (Platform.isIOS) {
      _calenderEventsPlugin.requestPermission();
      return;
    }
    if (!(await Permission.calendarFullAccess.isGranted)) {
      if (await Permission.calendarFullAccess.request().isGranted) {
        _checkPermission();
      }
    }*/
  }

  _checkPermission() async {
    havePermission = await _calenderEventsPlugin.checkCalendarPermission();
    setState(() {});
  }

  _listAccounts() async {
    accounts = await _calenderEventsPlugin.getCalendarAccounts();
    setState(() {});
  }

  void _showDialog(CalendarAccount account) {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            width: 100,
            height: 200,
            color: Theme.of(context).primaryColor,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  _addEvent(account);
                  Navigator.of(context).pop();
                },
                child: const Text('Add Event'),
              ),
            ),
          );
        });
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

    var bool = await _calenderEventsPlugin.addEvent(event);
    var showSnackBar = scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text('Calender added ${bool ? 'success' : 'failed'}')));

    bool = await _calenderEventsPlugin.requestSync(account);
    if (kDebugMode) {
      print('Syncing : $bool');
    }
  }
}
