package com.godwin.calendar_events


import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** CalendarEventsPlugin */
class CalendarEventsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PermissionResultCallback {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity
    private lateinit var result: Result
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.godwin/calendar_events")
        channel.setMethodCallHandler(this)

        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "requestPermission") {
            this.result = result
            CalendarEventManager.requestPermission(activity)
        } else if (call.method == "getCalendarAccounts") {
            val getResult = CalendarEventManager.getCalendars(context)
            if (getResult is CalendarListSuccess) {
                result.success(getResult.list)
            } else if (getResult is CalendarListFailed) {
                result.error(
                    getResult.error.errorCode,
                    getResult.error.details,
                    null,
                )
            }
        } else if (call.method == "checkPermission") {
            val havePermission = CalendarEventManager.checkCalendarPermission(context)
            if (havePermission) {
                result.success(1)
            } else {
                result.success(0)
            }
        } else if (call.method == "requestSync") {
            try {
                val map = call.arguments as Map<*, *>
                val accountName = map["accountName"] as String
                val accountType = map["accountType"] as String

                CalendarEventManager.requestSync(accountName, accountType)
                result.success(1)
            } catch (e: Exception) {
                e.printStackTrace()
                result.error("invalid_data", e.message, null)
            }
        } else if (call.method == "addEvent") {
            try {
                val map = call.arguments as Map<*, *>
                val event = CalendarUtil.convertToEvent(map)
                val eventResult = CalendarEventManager.addEventToCalendar(context, event)
                if (eventResult is CalendarEventSuccess) {
                    val eventMap = hashMapOf<String, String>()
                    eventMap["eventId"] = eventResult.event.eventId.toString()
                    result.success(eventMap)
                } else if (eventResult is CalendarEventFailed) {
                    result.error(eventResult.error.errorCode, eventResult.error.details, null)
                }
            } catch (e: Exception) {
                e.printStackTrace()
                result.error("invalid_data", e.message, null)
                return
            }
        } else if (call.method == "updateEvent") {
            try {
                val map = call.arguments as Map<*, *>
                val event = CalendarUtil.convertToEvent(map)
                val eventResult = CalendarEventManager.updateEvent(context, event)
                if (eventResult is CalendarEventSuccess) {
                    val eventMap = hashMapOf<String, String>()
                    eventMap["eventId"] = eventResult.event.eventId.toString()
                    result.success(eventMap)
                } else if (eventResult is CalendarEventFailed) {
                    result.error(eventResult.error.errorCode, eventResult.error.details, null)
                }
            } catch (e: Exception) {
                e.printStackTrace()
                result.error("invalid_data", e.message, null)
                return
            }
        } else if (call.method == "deleteEvent") {
            try {
                val map = call.arguments as Map<*, *>
                val eventId = (map["eventId"] as String?)
                val eventResult = CalendarEventManager.deleteEvent(context, eventId)
                if (eventResult is CalendarEventSuccess) {
                    val eventMap = hashMapOf<String, String>()
                    eventMap["eventId"] = eventResult.event.eventId.toString()
                    result.success(eventMap)
                } else if (eventResult is CalendarEventDeleteSuccess) {
                    val eventMap = hashMapOf<String, String>()
                    eventMap["eventId"] = eventResult.eventId
                    result.success(eventMap)
                } else if (eventResult is CalendarEventFailed) {
                    result.error(eventResult.error.errorCode, eventResult.error.details, null)
                }

            } catch (e: Exception) {
                e.printStackTrace()
                result.error("invalid_data", e.message, null)
                return
            }
        } else {
            result.notImplemented()
        }
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        CalendarEventManager.setActivityBinding(binding)
        CalendarEventManager.setPermissionCallback(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        CalendarEventManager.setActivityBinding(binding)
        CalendarEventManager.setPermissionCallback(this)
    }

    override fun onDetachedFromActivity() {
        CalendarEventManager.setActivityBinding(null)
    }

    override fun onSuccess() {
        result.success(1)
    }

    override fun onFailed(error: CalendarError) {
        result.error(error.errorCode, error.details, null)
    }

}
