package com.godwin.calendar_events

class CalenderEvent(
    val calenderId: Long,
    val title: String,
    val desc: String,
    val location: String,
    val start: Long,
    val end: Long,
    val timeZone: String?,
    val allDay: Int?,
    val reminderMin: Long?,
    val reminderType: Int?,
    val recurrence: String?,
    val emailInvites: List<EmailInvite>?
)

class EmailInvite(val emailId: String, val isRequired: Boolean)
