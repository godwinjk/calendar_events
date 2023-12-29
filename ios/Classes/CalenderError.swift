//
//  CalenderError.swift
//  calendar_events
//
//  Created by Godwin Joseph on 24/12/23.
//

import Foundation

class CalendarError {
    let errorCode: String
    let details: String

    init(errorCode: String, details: String) {
        self.errorCode = errorCode
        self.details = details
    }
}
