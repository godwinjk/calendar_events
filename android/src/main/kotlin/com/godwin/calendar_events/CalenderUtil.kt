package com.godwin.calendar_events

import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

internal class CalenderUtil {
    companion object {
        fun convertToEvent(map: Map<*, *>): CalenderEvent {
            val calenderId = (map["calendarId"] as Number).toLong()
            val title = (map["title"] as String?) ?: ""
            val desc = (map["description"] as String?) ?: ""
            val location = (map["location"] as String?) ?: ""
            val start = (map["start"] as Number).toLong()
            val end = (map["end"] as Number).toLong()
            val timeZone = map["timeZone"] as String?
            val allDay = map["allDay"] as Int?
            val recurrence = map["recurrence"] as Map<*, *>?
            val reminderMin = (map["reminderMinutes"] as Number?)?.toLong()
            val reminderType = map["reminderType"] as Int?
            val emailInvites = map["reminderType"] as List<*>?

            var recurrenceRule: String? = null
            if (null != recurrence) {
                recurrenceRule = buildRRule(recurrence)
            }

            val emailInvitesList: List<EmailInvite>? = mapEmailInvites(emailInvites)

            return CalenderEvent(
                calenderId,
                title,
                desc,
                location,
                start,
                end,
                timeZone,
                allDay,
                reminderMin,
                reminderType,
                recurrenceRule,
                emailInvitesList,
            )
        }

        private fun buildRRule(recurrence: Map<*, *>): String {
            var rRule = recurrence["rRule"] as String?
            if (rRule == null) {
                rRule = ""
                val freqEnum: Int? = recurrence["frequency"] as Int?
                if (freqEnum != null) {
                    rRule += "FREQ="
                    when (freqEnum) {
                        0 -> rRule += "DAILY"
                        1 -> rRule += "WEEKLY"
                        2 -> rRule += "MONTHLY"
                        3 -> rRule += "YEARLY"
                    }
                    rRule += ";"
                }
                rRule += "INTERVAL=" + recurrence["interval"] as Int + ";"
                val occurrences: Int? = recurrence["ocurrences"] as Int?
                if (occurrences != null) {
                    rRule += "COUNT=" + occurrences.toInt().toString() + ";"
                }
                val endDateMillis = recurrence["endDate"] as Long?
                if (endDateMillis != null) {
                    val endDate = Date(endDateMillis)
                    val formatter: DateFormat =
                        SimpleDateFormat("yyyyMMdd'T'HHmmss", Locale.getDefault())
                    rRule += "UNTIL=" + formatter.format(endDate).toString() + ";"
                }
            }
            return rRule
        }

        private fun mapEmailInvites(list: List<*>?): List<EmailInvite>? {
            return list?.map {
                val map = it as Map<*, *>
                EmailInvite(map["emailInvite"] as String, ((map["required"] as Int) == 1))
            }?.toList()

        }
    }
}