///authorized: Access is already granted, proceed with fetching calendar accounts
///denied: Access denied, prompt the user to grant access
///denied: Access denied, prompt the user to grant access
///notDetermined:Request access to the calendar
///restricted: The app is not authorized to access the user's calendar data
///writeOnly: Write Only
///noIdea: We have no idea, rare case
enum CalendarPermission {
  denied,
  allowed,
  notDetermined,
  restricted,
  writeOnly,
  noIdea;

  static CalendarPermission fromInt(int value) {
    if (value == 0) {
      return CalendarPermission.denied;
    } else if (value == 1) {
      return CalendarPermission.allowed;
    } else if (value == 2) {
      return CalendarPermission.writeOnly;
    } else if (value == 3) {
      return CalendarPermission.notDetermined;
    } else if (value == 3) {
      return CalendarPermission.restricted;
    }
    return CalendarPermission.noIdea;
  }
}
