//
//  CalendarUtil.swift
//  calendar_events
//
//  Created by Godwin Joseph on 27/12/23.
//

import Foundation

class CalendarUtil {
    static func convertToEvent(from map: [String: Any]) -> CalendarEvent {
        let eventId = map["eventId"] as? String
        let calendarId = map["calendarId"] as? String
        let title = map["title"] as? String ?? ""
        let desc = map["description"] as? String ?? ""
        let location = map["location"] as? String ?? ""
        let start = (map["start"] as? NSNumber)?.int64Value ?? 0
        let end = (map["end"] as? NSNumber)?.int64Value ?? 0
        let timeZone = map["timeZone"] as? String
        let allDay = map["allDay"] as? Int
        let reminderSec = (map["reminderSeconds"] as? NSNumber)?.doubleValue
        let recurrence = map["recurrence"] as? [String: Any]
        let url = map["url"] as? String
        
        return CalendarEvent(
            eventId: eventId,
            calendarId: calendarId,
            title: title,
            desc: desc,
            location: location,
            start: start,
            end: end,
            timeZone: timeZone,
            allDay: allDay,
            reminderSec: reminderSec,
            recurrence: recurrence,
            url:url
        )
    }
}
