package com.godwin.calendar_events

sealed interface CalenderListResult

class CalenderListSuccess(val list: List<Map<String, Any>>) : CalenderListResult
class CalenderListFailed(val error: CalenderError) : CalenderListResult

