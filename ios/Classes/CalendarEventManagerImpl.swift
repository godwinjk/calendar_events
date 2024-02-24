//
//  CalenderEventsManagerImpl.swift
//  calendar_events
//
//  Created by Godwin Joseph on 24/12/23.
//

import Foundation
import EventKit

class CalendarEventsManagerImpl : CalendarEventManager{

    let eventStore = EKEventStore()
    
    func checkPermission()->Int {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            // Access is already granted, proceed with fetching calendar accounts
            return 1
        case .denied:
            // Access denied, prompt the user to grant access
            print("Access denied. Please enable calendar access in Settings.")
            return 0
        case .notDetermined:
            // Request access to the calendar
            return 3
        case .restricted:
            // The app is not authorized to access the user's calendar data
            print("Access restricted. The app is not authorized to access the user's calendar data.")
            return 4
        case .fullAccess:
            return 1
        case .writeOnly:
            return 2
        @unknown default:
            return -1;
        }
    }
    
    func requestPermission(callback: @escaping (Int) -> Void){
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents(completion:   { (granted, error) in
                if granted {
                    // Access granted, proceed with fetching calendar accounts
                    callback( 1)
                } else {
                    // Access denied by the user
                    callback(0)
                }
            })
        } else {
            // Fallback on earlier versions
            eventStore.requestAccess(to: .event, completion:  { (granted, error) in
                if granted {
                    // Access granted, proceed with fetching calendar accounts
                    callback( 1)
                } else {
                    // Access denied by the user
                    callback(0)
                }
            })
        }
        
    }
    
    func getCalendarAccounts()-> CalendarListResult{
        var list :[Dictionary<String,Any>] = []
        // Fetching calendar accounts
        let calendars = eventStore.calendars(for: .event)
        
        for calendar in calendars {
            var dict = Dictionary<String,Any>()
            dict["calendarId"] = calendar.calendarIdentifier
            dict["accountName"] = calendar.title
            var accountType = "unknown"
            switch calendar.type {
            case .local:
                accountType = "local"
            case .calDAV:
                accountType = "calDAV"
            case .exchange:
                accountType = "exchange"
            case .subscription:
                accountType = "subscription"
            case .birthday:
                accountType = "birthday"
            @unknown default:
                accountType = "unknown"
            }
            dict["accountType"] = accountType
            dict["sourceId"] = calendar.source.sourceIdentifier
            dict["sourceTitle"] = calendar.source.title
            
            var sourceType = "unknown"
            switch calendar.source.sourceType {
            case .local:
                sourceType = "local"
            case .exchange:
                sourceType = "exchange"
            case .calDAV:
                sourceType = "calDAV"
            case .mobileMe:
                sourceType = "mobileMe"
            case .subscribed:
                sourceType = "subscribed"
            case .birthdays:
                sourceType = "birthdays"
            @unknown default:
                sourceType = "unknown"
            }
            
            dict["sourceType"] = sourceType
            
            list.append(dict)
        }
        return CalendarListResult.success(list: list)
        
    }
    
    func addEvent(calendarEvent: CalendarEvent) -> CalendarEventResult{
        let event = EKEvent(eventStore: eventStore)
        if let alarm = calendarEvent.reminderSec{
            event.addAlarm(EKAlarm(relativeOffset: alarm*(-1)))
        }
        event.title = calendarEvent.title
        event.startDate = Date(timeIntervalSince1970: TimeInterval(calendarEvent.start/1000))
        event.endDate = Date(timeIntervalSince1970: TimeInterval(calendarEvent.end/1000))
        if (calendarEvent.timeZone != nil) {
            event.timeZone = TimeZone(identifier: calendarEvent.timeZone!)
        }
        event.location = calendarEvent.location
        
        event.notes = calendarEvent.desc
        
        if let url = calendarEvent.url{
            event.url = URL(string: url);
        }
        if let allDay = calendarEvent.allDay{
            event.isAllDay = (allDay == 1)
        }
        
        if let recurrence = calendarEvent.recurrence {
            let interval = recurrence["interval"] as! Int
            let frequency = recurrence["frequency"] as! Int
            let end = recurrence["endDate"] as? Double// Date(milliseconds: (args["startDate"] as! Double))
            let ocurrences = recurrence["ocurrences"] as? Int
            
            let recurrenceRule = EKRecurrenceRule.init(
                recurrenceWith: EKRecurrenceFrequency(rawValue: frequency)!,
                interval: interval,
                end: ocurrences != nil ? EKRecurrenceEnd.init(occurrenceCount: ocurrences!) : end != nil ? EKRecurrenceEnd.init(end: Date(timeIntervalSince1970: end!)) : nil
            )
            event.recurrenceRules = [recurrenceRule]
        }
        
        if let calendarId = calendarEvent.calendarId {
            let calendar = eventStore.calendar(withIdentifier: calendarId)
            if let calendar = calendar{
                event.calendar = calendar
            }
        } else {
            event.calendar = eventStore.defaultCalendarForNewEvents
        }
        
        do {
            // Save the event to the calendar
            try eventStore.save(event, span: .thisEvent)
            calendarEvent.eventId = event.eventIdentifier
            return CalendarEventResult.success(event: calendarEvent)
        } catch {
            return CalendarEventResult.failed(error: CalendarError(errorCode:"exception_occurred",details: error.localizedDescription))
        }
    }
    
    func updateEvent(calendarEvent: CalendarEvent) ->  CalendarEventResult{
        guard let eventId = calendarEvent.eventId else {
            return CalendarEventResult.failed(error: CalendarError(errorCode: "event_id_missing", details: "Event id is missing"))
        }
        guard let event = eventStore.event(withIdentifier: eventId) else {
            return CalendarEventResult.failed(error:CalendarError(errorCode: "event_not_found", details: "Event with identifier \(eventId) not found"))
        }
        
        event.title = calendarEvent.title
        event.startDate = Date(timeIntervalSince1970: TimeInterval(calendarEvent.start/1000))
        event.endDate = Date(timeIntervalSince1970: TimeInterval(calendarEvent.end/1000))
        if (calendarEvent.timeZone != nil) {
            event.timeZone = TimeZone(identifier: calendarEvent.timeZone!)
        }
        event.location = calendarEvent.location
        
        event.notes = calendarEvent.desc
        
        if let url = calendarEvent.url{
            event.url = URL(string: url);
        }
        if let allDay = calendarEvent.allDay{
            event.isAllDay = (allDay == 1)
        }
        
        if let recurrence = calendarEvent.recurrence {
            let interval = recurrence["interval"] as! Int
            let frequency = recurrence["frequency"] as! Int
            let end = recurrence["endDate"] as? Double// Date(milliseconds: (args["startDate"] as! Double))
            let ocurrences = recurrence["ocurrences"] as? Int
            
            let recurrenceRule = EKRecurrenceRule.init(
                recurrenceWith: EKRecurrenceFrequency(rawValue: frequency)!,
                interval: interval,
                end: ocurrences != nil ? EKRecurrenceEnd.init(occurrenceCount: ocurrences!) : end != nil ? EKRecurrenceEnd.init(end: Date(timeIntervalSince1970: end!)) : nil
            )
            event.recurrenceRules = [recurrenceRule]
        }
        
        if let calendarId = calendarEvent.calendarId {
            let calendar = eventStore.calendar(withIdentifier: calendarId)
            if let calendar = calendar{
                event.calendar = calendar
            }
        } else {
            event.calendar = eventStore.defaultCalendarForNewEvents
        }
        
        do {
            // Save the event to the calendar
            try eventStore.save(event, span: .thisEvent)
            calendarEvent.eventId = event.eventIdentifier
            return CalendarEventResult.success(event: calendarEvent)
        } catch {
            return CalendarEventResult.failed(error: CalendarError(errorCode:"exception_occurred",details: error.localizedDescription))
        }
        
        
    }
    
    func deleteEvent(eventId: String?) -> CalendarEventResult {
        guard let eventId = eventId else {
            return CalendarEventResult.failed(error: CalendarError(errorCode: "event_id_missing", details: "Event id is missing"))
        }
        guard let event = eventStore.event(withIdentifier: eventId) else {
            return CalendarEventResult.failed(error:CalendarError(errorCode: "event_not_found", details: "Event with identifier \(eventId) not found"))
        }
        
        do {
            // Delete the event from the calendar
            try eventStore.remove(event, span: .thisEvent)
            return CalendarEventResult.deleteSuccess(eventId: eventId)
        } catch {
            return CalendarEventResult.failed(error: CalendarError(errorCode:"exception_occurred",details: error.localizedDescription))
        }
    }
}
