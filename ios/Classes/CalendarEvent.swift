//
//  CalendarEvent.swift
//  calendar_events
//
//  Created by Godwin Joseph on 24/12/23.
//

import Foundation

class CalendarEvent {
    var eventId: String?
    let calendarId: String?
    let title: String
    let desc: String
    let location: String
    let start: Int64
    let end: Int64
    let timeZone: String?
    let allDay: Int?
    let reminderSec: Double?
    let recurrence: [String:Any]?
    let url:String?
    init(
        eventId: String?,
        calendarId: String?,
        title: String,
        desc: String,
        location: String,
        start: Int64,
        end: Int64,
        timeZone: String?,
        allDay: Int?,
        reminderSec: Double?,
        recurrence: [String:Any]?,
        url:String?
    ) {
        self.eventId = eventId
        self.calendarId = calendarId
        self.title = title
        self.desc = desc
        self.location = location
        self.start = start
        self.end = end
        self.timeZone = timeZone
        self.allDay = allDay
        self.reminderSec = reminderSec
        self.recurrence = recurrence
        self.url = url
    }
}
