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
                do{
                    let calendarEvent = try CalendarUtil.convertToEvent(from: map)
                    let error = calendarManager.addEvent(calendarEvent: calendarEvent)
                    if(error != nil){
                        result(FlutterError(code:error!.errorCode,message: error?.details,details: nil))
                    }else {
                        result(1)
                    }
                }catch {
                    result(FlutterError(code:"exception_occurred",message: error.localizedDescription,details: nil))
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
