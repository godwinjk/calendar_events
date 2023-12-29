//
//  CalendarResult.swift
//  calendar_events
//
//  Created by Godwin Joseph on 25/12/23.
//

import Foundation

enum CalendarListResult {
    case success(list: [Dictionary<String, Any>])
    case failed(error: CalendarError)
}




