import Flutter
import UIKit

public class CalendarEventsPlugin: NSObject, FlutterPlugin {
    
    let calendarManager :CalendarEventManager = CalendarEventsManagerImpl()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.godwin/calendar_events", binaryMessenger: registrar.messenger())
        let instance = CalendarEventsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkPermission":
            let permission = calendarManager.checkPermission()
            result(permission)
            break
        case "requestPermission":
            calendarManager.requestPermission{intValue in  result(intValue)}
            break
        case "addEvent":
            if let map = call.arguments as? [String: Any] {
                let calendarEvent =  CalendarUtil.convertToEvent(from: map)
                let eventresult: CalendarEventResult = calendarManager.addEvent(calendarEvent: calendarEvent)
                switch eventresult{
                case .success(let event) :
                    result(["eventId": event.eventId])
                    break
                case .failed(let error) :
                    result(FlutterError(code:error.errorCode,message: error.details,details: nil))
                    break
                case .deleteSuccess(eventId: _):
                    break
                }
            } else {
                result(FlutterError(
                    code: "ARGUMENT_ERROR",
                    message: "Invalid arguments",
                    details: nil
                ))
            }
            break
        case "updateEvent":
            if let map = call.arguments as? [String: Any] {
                let calendarEvent =  CalendarUtil.convertToEvent(from: map)
                let eventresult = calendarManager.updateEvent(calendarEvent: calendarEvent)
                switch eventresult{
                case .success(let event) :
                    result(["eventId": event.eventId])
                    break
                case .failed(let error) :
                    result(FlutterError(code:error.errorCode,message: error.details,details: nil))
                    break
                case .deleteSuccess(eventId: _):
                    break
                }
                
            } else {
                result(FlutterError(
                    code: "ARGUMENT_ERROR",
                    message: "Invalid arguments",
                    details: nil
                ))
            }
            break
        case "deleteEvent":
            if let map = call.arguments as? [String: Any] {
                let eventId = map["eventId"] as? String
                let eventresult = calendarManager.deleteEvent(eventId: eventId)
                switch eventresult{
                case .success(_) :
                    break
                case .failed(let error) :
                    result(FlutterError(code:error.errorCode,message: error.details,details: nil))
                    break
                case .deleteSuccess(eventId: let eventId):
                    result(["eventId": eventId])
                }
            } else {
                result(FlutterError(
                    code: "ARGUMENT_ERROR",
                    message: "Invalid arguments",
                    details: nil
                ))
            }
            break
        case "getCalendarAccounts":
            let calendarResult  = calendarManager.getCalendarAccounts()
            switch calendarResult {
            case .success(let list):
                result(list)
            case .failed(let error):
                result(FlutterError(
                    code: error.errorCode,
                    message: error.details,
                    details: nil
                ))
            }
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
