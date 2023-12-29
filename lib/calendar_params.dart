import 'calendar_reminder_type.dart';

class AndroidParams {
  final List<EmailAttendee>? emailInvites;
  final int? reminderMinutes;
  final CalendarReminderType? reminderType;

  const AndroidParams(
      {this.reminderMinutes, this.reminderType, this.emailInvites});

}

class EmailAttendee {
  final String emailId;
  final bool required;

  EmailAttendee(this.emailId, {this.required = true});

  Map<String, dynamic> toJson() {
    return {
      'email': emailId,
      'required': required ?1:0
      // Add other properties if needed
    };
  }
}

class IosParams {
  final Duration? reminder;
  final String? url;

  IosParams({this.reminder, this.url});
}
