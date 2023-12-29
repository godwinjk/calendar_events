//
//  CalendarEventManager.swift
//  calendar_events
//
//  Created by Godwin Joseph on 24/12/23.
//

import Foundation

protocol CalendarEventManager{
    func checkPermission()->Int
    
    func requestPermission(callback: @escaping (Int) -> Void)
    
    func getCalendarAccounts()-> CalendarListResult
    
    func addEvent(calendarEvent: CalendarEvent) -> CalendarError?
}
