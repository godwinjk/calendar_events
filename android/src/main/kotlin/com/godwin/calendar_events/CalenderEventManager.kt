package com.godwin.calendar_events

import android.Manifest
import android.accounts.Account
import android.content.ContentResolver
import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.CalendarContract
import androidx.core.content.ContextCompat
import java.util.TimeZone

object CalenderEventManager {

    fun requestSync(accountName: String, accountType: String) {
        // Specify the account and authority for the calendar you want to sync
        val account =
            Account(accountName, accountType) // Replace with your account details

        val authority = CalendarContract.AUTHORITY

        // Set up the extras (optional)
        val extras = Bundle()
        extras.putBoolean(ContentResolver.SYNC_EXTRAS_MANUAL, true) // Trigger a manual sync
        extras.putBoolean(
            ContentResolver.SYNC_EXTRAS_EXPEDITED,
            true
        ) // Expedite the sync if possible


        // Request a sync for the specified account and authority
        ContentResolver.requestSync(account, authority, extras)
    }

    fun getCalenders(context: Context): CalenderListResult {
        val listOfCalender = mutableListOf<Map<String, Any>>()
        if (checkCalenderPermission(context)) {
            val projection = arrayOf(
                CalendarContract.Calendars._ID,
                CalendarContract.Calendars.ACCOUNT_NAME,
                CalendarContract.Calendars.ACCOUNT_TYPE
            )
            val uri: Uri = CalendarContract.Calendars.CONTENT_URI
            // Query for all calendars
            val cursor = context.contentResolver.query(uri, projection, null, null, null)

            cursor?.use {
                while (it.moveToNext()) {
                    try {
                        val calendarId =
                            it.getLong(it.getColumnIndex(CalendarContract.Calendars._ID))
                        val accountName =
                            it.getString(it.getColumnIndex(CalendarContract.Calendars.ACCOUNT_NAME))
                        val accountType =
                            it.getString(it.getColumnIndex(CalendarContract.Calendars.ACCOUNT_TYPE))

                        val calenderMap = hashMapOf<String, Any>()
                        calenderMap["calendarId"] = calendarId
                        calenderMap["accountName"] = accountName
                        calenderMap["accountType"] = accountType
                        listOfCalender.add(calenderMap)
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
        } else {
            return CalenderListFailed(
                CalenderError(
                    "permission_denied",
                    "Please give calender permission"
                )
            )
        }
        return CalenderListSuccess(listOfCalender)
    }

    fun addEventToCalendar(
        context: Context,
        calenderEvent: CalenderEvent
    ): CalenderError? {
        try {
            val cr: ContentResolver = context.contentResolver
            val values = ContentValues()

            // Calendar
            values.put(
                CalendarContract.Events.CALENDAR_ID,
                calenderEvent.calenderId
            )  // Use 1 for the primary calendar

            // Event details
            values.put(CalendarContract.Events.TITLE, calenderEvent.title)
            values.put(CalendarContract.Events.EVENT_LOCATION, calenderEvent.location)
            values.put(CalendarContract.Events.DESCRIPTION, calenderEvent.desc)

            // Time
            values.put(CalendarContract.Events.DTSTART, calenderEvent.start)
            values.put(CalendarContract.Events.DTEND, calenderEvent.end)

            val allDay = if (calenderEvent.allDay == null) false else calenderEvent.allDay == 1
            values.put(CalendarContract.EXTRA_EVENT_ALL_DAY, allDay)
            val timezone =
                calenderEvent.timeZone ?: TimeZone.getDefault().id
            values.put(CalendarContract.Events.EVENT_TIMEZONE, timezone)  // 2 hours

            // Status
            values.put(CalendarContract.Events.STATUS, CalendarContract.Events.STATUS_CONFIRMED)
            if (calenderEvent.recurrence != null) {
                values.put(CalendarContract.Events.RRULE, calenderEvent.recurrence)
            }
            // Save the event
            val uri: Uri? = cr.insert(CalendarContract.Events.CONTENT_URI, values)
            val eventId: Long = uri!!.lastPathSegment!!.toLong()

            val cValues = ContentValues()
            values.put(CalendarContract.Calendars.SYNC_EVENTS, 1)
            values.put(CalendarContract.Calendars.VISIBLE, 1)

            cr.update(
                ContentUris.withAppendedId(CalendarContract.Calendars.CONTENT_URI, eventId),
                cValues,
                null,
                null
            )
            // Optionally, you can set reminders for the event
            if (calenderEvent.reminderType != null) {
                setEventReminders(cr, eventId, calenderEvent)
            }
            calenderEvent.emailInvites
            if(calenderEvent.emailInvites!= null){

            }
        } catch (e: Exception) {
            e.printStackTrace()
            return CalenderError("exception_occurred", e.message ?: "Exception Occurred")
        }
        return null
    }

    private fun setEventReminders(
        cr: ContentResolver,
        eventId: Long,
        calenderEvent: CalenderEvent
    ) {
        val values = ContentValues()
        values.put(
            CalendarContract.Reminders.MINUTES,
            calenderEvent.reminderMin ?: 15
        )  // 15 minutes before the event
        values.put(CalendarContract.Reminders.EVENT_ID, eventId)
        values.put(
            CalendarContract.Reminders.METHOD,
            calenderEvent.reminderType ?: CalendarContract.Reminders.METHOD_ALERT
        )
        cr.insert(CalendarContract.Reminders.CONTENT_URI, values)
    }

    private fun setEmailAttendees(list: List<EmailInvite>){

    }
    fun checkCalenderPermission(context: Context) = ContextCompat.checkSelfPermission(
        context,
        Manifest.permission.READ_CALENDAR
    ) == PackageManager.PERMISSION_GRANTED &&
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.WRITE_CALENDAR
            ) == PackageManager.PERMISSION_GRANTED
}