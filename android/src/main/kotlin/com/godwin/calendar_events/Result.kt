package com.godwin.calendar_events

sealed interface CalendarListResult

class CalendarListSuccess(val list: List<Map<String, Any?>>) : CalendarListResult
class CalendarListFailed(val error: CalendarError) : CalendarListResult

sealed interface CalendarEventResult

class CalendarEventSuccess(val event: CalendarEvent) : CalendarEventResult
class CalendarEventDeleteSuccess(val eventId: String) : CalendarEventResult
class CalendarEventFailed(val error: CalendarError) : CalendarEventResult