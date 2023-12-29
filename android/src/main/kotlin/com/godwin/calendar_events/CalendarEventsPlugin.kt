package com.godwin.calendar_events


import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** CalendarEventsPlugin */
class CalendarEventsPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.godwin/calendar_events")
        channel.setMethodCallHandler(this)

        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "getCalenderAccounts") {
            val getResult = CalenderEventManager.getCalenders(context)
            if (getResult is CalenderListSuccess) {
                result.success(getResult.list)
            } else if (getResult is CalenderListFailed) {
                result.error(
                    getResult.error.errorCode,
                    getResult.error.details,
                    null,
                )
            }
        } else if (call.method == "checkPermission") {
            val havePermission = CalenderEventManager.checkCalenderPermission(context)
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

                CalenderEventManager.requestSync(accountName, accountType)
                result.success(1)
            } catch (e: Exception) {
                e.printStackTrace()
                result.error("invalid_data", e.message, null)
            }
        } else if (call.method == "addEvent") {
            try {
                val map = call.arguments as Map<*, *>
                val event = CalenderUtil.convertToEvent(map)
                val error = CalenderEventManager.addEventToCalendar(context, event)
                if (error != null) {
                    result.error(error.errorCode, error.details, null)
                }
            } catch (e: Exception) {
                e.printStackTrace()
                result.error("invalid_data", e.message, null)
                return
            }
            result.success(1)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
