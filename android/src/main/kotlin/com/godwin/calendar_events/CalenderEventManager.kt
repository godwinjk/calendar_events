package com.godwin.calendar_events

import android.Manifest
import android.accounts.Account
import android.app.Activity
import android.content.ContentResolver
import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.CalendarContract
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry
import java.util.TimeZone

object CalendarEventManager :
    PluginRegistry.RequestPermissionsResultListener {
    private const val REQUEST_CODE = 102
    private var binding: ActivityPluginBinding? = null
    private lateinit var callback: PermissionResultCallback
    fun requestPermission(activity: Activity) {
        if (checkCalendarPermission(activity)) {
            callback.onSuccess()
            return
        }
        val permissions =
            arrayOf(Manifest.permission.READ_CALENDAR, Manifest.permission.WRITE_CALENDAR)
        ActivityCompat.requestPermissions(activity, permissions, REQUEST_CODE)
    }

    fun setActivityBinding(binding: ActivityPluginBinding?) {
        binding?.addRequestPermissionsResultListener(this)
        this.binding = binding
    }

    fun setPermissionCallback(callback: PermissionResultCallback) {
        this.callback = callback
    }

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

    fun getCalendars(context: Context): CalendarListResult {
        val listOfCalendar = mutableListOf<Map<String, Any?>>()
        if (checkCalendarPermission(context)) {
            val projection = arrayOf(
                CalendarContract.Calendars._ID,
                CalendarContract.Calendars.ACCOUNT_NAME,
                CalendarContract.Calendars.ACCOUNT_TYPE,
                CalendarContract.Calendars.IS_PRIMARY,
                CalendarContract.Calendars.OWNER_ACCOUNT,
                CalendarContract.Calendars.CALENDAR_DISPLAY_NAME,
                CalendarContract.Calendars.NAME,
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
                        val isPrimary =
                            it.getInt(it.getColumnIndex(CalendarContract.Calendars.IS_PRIMARY))
                        val displayName =
                            it.getString(it.getColumnIndex(CalendarContract.Calendars.CALENDAR_DISPLAY_NAME))
                        val ownerAccount =
                            it.getString(it.getColumnIndex(CalendarContract.Calendars.OWNER_ACCOUNT))
                        val name =
                            it.getString(it.getColumnIndex(CalendarContract.Calendars.NAME))

                        val calendarMap = hashMapOf<String, Any?>()
                        calendarMap["calendarId"] = calendarId.toString()
                        calendarMap["accountName"] = accountName
                        calendarMap["accountType"] = accountType
                        calendarMap["isPrimary"] = isPrimary
                        calendarMap["ownerAccount"] = ownerAccount
                        calendarMap["displayName"] = displayName
                        calendarMap["name"] = name
                        listOfCalendar.add(calendarMap)
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
        } else {
            return CalendarListFailed(
                CalendarError(
                    "permission_denied",
                    "Please give calendar permission"
                )
            )
        }
        return CalendarListSuccess(listOfCalendar)
    }

    fun addEventToCalendar(
        context: Context,
        calendarEvent: CalendarEvent
    ): CalendarEventResult {
        try {
            val cr: ContentResolver = context.contentResolver
            val values = ContentValues()

            // Calendar
            values.put(
                CalendarContract.Events.CALENDAR_ID,
                calendarEvent.calendarId
            )  // Use 1 for the primary calendar

            // Event details
            values.put(CalendarContract.Events.TITLE, calendarEvent.title)
            values.put(CalendarContract.Events.EVENT_LOCATION, calendarEvent.location)
            values.put(CalendarContract.Events.DESCRIPTION, calendarEvent.desc)

            // Time
            values.put(CalendarContract.Events.DTSTART, calendarEvent.start)
            values.put(CalendarContract.Events.DTEND, calendarEvent.end)

            val allDay = if (calendarEvent.allDay == null) false else calendarEvent.allDay == 1
            values.put(CalendarContract.EXTRA_EVENT_ALL_DAY, allDay)
            val timezone =
                calendarEvent.timeZone ?: TimeZone.getDefault().id
            values.put(CalendarContract.Events.EVENT_TIMEZONE, timezone)  // 2 hours

            // Status
            values.put(CalendarContract.Events.STATUS, CalendarContract.Events.STATUS_CONFIRMED)
            if (calendarEvent.recurrence != null) {
                values.put(CalendarContract.Events.RRULE, calendarEvent.recurrence)
            }
            // Save the event
            val uri: Uri? = cr.insert(CalendarContract.Events.CONTENT_URI, values)
            val eventId: Long = uri!!.lastPathSegment!!.toLong()

            calendarEvent.eventId = eventId.toString()

            val cValues = ContentValues()
            cValues.put(CalendarContract.Calendars.SYNC_EVENTS, 1)
            cValues.put(CalendarContract.Calendars.VISIBLE, 1)

            cr.update(
                ContentUris.withAppendedId(CalendarContract.Calendars.CONTENT_URI, eventId),
                cValues,
                null,
                null
            )
            // Optionally, you can set reminders for the event
            if (calendarEvent.reminderType != null) {
                setEventReminders(cr, eventId, calendarEvent)
            }
            if (calendarEvent.emailInvites != null) {
                setEmailAttendees(cr, eventId, calendarEvent.emailInvites)
            }
        } catch (e: Exception) {
            e.printStackTrace()
            return CalendarEventFailed(
                CalendarError(
                    "exception_occurred",
                    e.message ?: "Exception Occurred"
                )
            )
        }

        return CalendarEventSuccess(calendarEvent)
    }

    fun updateEvent(
        context: Context,
        calendarEvent: CalendarEvent
    ): CalendarEventResult {
        try {
            if (calendarEvent.eventId == null) return CalendarEventFailed(
                CalendarError(
                    "event_id_missing",
                    "Event id missing, can't proceed"
                )
            )
            val cr: ContentResolver = context.contentResolver
            val values = ContentValues()

            // Calendar
            values.put(
                CalendarContract.Events.CALENDAR_ID,
                calendarEvent.calendarId
            )  // Use 1 for the primary calendar

            // Event details
            values.put(CalendarContract.Events.TITLE, calendarEvent.title)
            values.put(CalendarContract.Events.EVENT_LOCATION, calendarEvent.location)
            values.put(CalendarContract.Events.DESCRIPTION, calendarEvent.desc)

            // Time
            values.put(CalendarContract.Events.DTSTART, calendarEvent.start)
            values.put(CalendarContract.Events.DTEND, calendarEvent.end)

            val allDay = if (calendarEvent.allDay == null) false else calendarEvent.allDay == 1
            values.put(CalendarContract.EXTRA_EVENT_ALL_DAY, allDay)
            val timezone =
                calendarEvent.timeZone ?: TimeZone.getDefault().id
            values.put(CalendarContract.Events.EVENT_TIMEZONE, timezone)  // 2 hours

            // Status
            values.put(CalendarContract.Events.STATUS, CalendarContract.Events.STATUS_CONFIRMED)
            if (calendarEvent.recurrence != null) {
                values.put(CalendarContract.Events.RRULE, calendarEvent.recurrence)
            }
            val eventId = calendarEvent.eventId?.toLong() ?: 0

            val cValues = ContentValues()
            cValues.put(CalendarContract.Calendars.SYNC_EVENTS, 1)
            cValues.put(CalendarContract.Calendars.VISIBLE, 1)

            cr.update(
                ContentUris.withAppendedId(CalendarContract.Calendars.CONTENT_URI, eventId),
                cValues,
                null,
                null
            )
            val rows = cr.update(
                ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, eventId),
                values,
                null,
                null
            )
            // Optionally, you can set reminders for the event
            if (calendarEvent.reminderType != null) {
                cr.delete(
                    CalendarContract.Reminders.CONTENT_URI,
                    "${CalendarContract.Reminders.EVENT_ID}=?",
                    arrayOf(eventId.toString())
                )
                setEventReminders(cr, eventId, calendarEvent)
            }
            if (calendarEvent.emailInvites != null) {
                cr.delete(
                    CalendarContract.Attendees.CONTENT_URI,
                    "${CalendarContract.Attendees.EVENT_ID}=?",
                    arrayOf(eventId.toString())
                )
                setEmailAttendees(cr, eventId, calendarEvent.emailInvites)
            }
            return if (rows > 0)
                CalendarEventSuccess(calendarEvent)
            else CalendarEventFailed(CalendarError("no_rows_affected", "No rows affected"))
        } catch (e: Exception) {
            e.printStackTrace()
            return CalendarEventFailed(
                CalendarError(
                    "exception_occurred",
                    e.message ?: "Exception Occurred"
                )
            )
        }
    }

    fun deleteEvent(
        context: Context,
        eventId: String?
    ): CalendarEventResult {
        try {
            if (eventId == null) return CalendarEventFailed(
                CalendarError(
                    "event_id_missing",
                    "Event id missing, can't proceed"
                )
            )

            val cr: ContentResolver = context.contentResolver

            val eventIdLng = eventId.toLong()
            val rows = cr.delete(
                ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, eventIdLng),
                null,
                null
            )
            cr.delete(
                CalendarContract.Reminders.CONTENT_URI,
                "${CalendarContract.Reminders.EVENT_ID}=?",
                arrayOf(eventId.toString())
            )

            cr.delete(
                CalendarContract.Attendees.CONTENT_URI,
                "${CalendarContract.Attendees.EVENT_ID}=?",
                arrayOf(eventId.toString())
            )
            return if (rows > 0)
                CalendarEventDeleteSuccess(eventId)
            else CalendarEventFailed(CalendarError("no_rows_affected", "No rows affected"))
        } catch (e: Exception) {
            e.printStackTrace()
            return CalendarEventFailed(
                CalendarError(
                    "exception_occurred",
                    e.message ?: "Exception Occurred"
                )
            )
        }
    }

    private fun setEventReminders(
        cr: ContentResolver,
        eventId: Long,
        calendarEvent: CalendarEvent
    ) {
        val values = ContentValues()
        values.put(
            CalendarContract.Reminders.MINUTES,
            calendarEvent.reminderMin ?: 15
        )  // 15 minutes before the event
        values.put(CalendarContract.Reminders.EVENT_ID, eventId)
        values.put(
            CalendarContract.Reminders.METHOD,
            calendarEvent.reminderType ?: CalendarContract.Reminders.METHOD_ALERT
        )
        cr.insert(CalendarContract.Reminders.CONTENT_URI, values)
    }

    private fun setEmailAttendees(
        cr: ContentResolver,
        eventId: Long, list: List<EmailInvite>
    ) {
        list.forEach {
            val attendeeValues = ContentValues()
            attendeeValues.put(CalendarContract.Attendees.EVENT_ID, eventId);
            attendeeValues.put(CalendarContract.Attendees.ATTENDEE_EMAIL, it.emailId);
            attendeeValues.put(
                CalendarContract.Attendees.ATTENDEE_TYPE,
                if (it.isRequired) CalendarContract.Attendees.TYPE_REQUIRED else CalendarContract.Attendees.TYPE_OPTIONAL
            );
            cr.insert(CalendarContract.Attendees.CONTENT_URI, attendeeValues);
        }
    }

    fun checkCalendarPermission(context: Context) = ContextCompat.checkSelfPermission(
        context,
        Manifest.permission.READ_CALENDAR
    ) == PackageManager.PERMISSION_GRANTED &&
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.WRITE_CALENDAR
            ) == PackageManager.PERMISSION_GRANTED

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == REQUEST_CODE) {
            val isGranted = grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED
            if (isGranted) callback.onSuccess()
            else callback.onFailed(
                CalendarError(
                    "permission_not_granted",
                    "Permission not granted ${permissions[0]}:${grantResults[0]}"
                )
            )
        }
        return true
    }
}