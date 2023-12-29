package com.godwin.calendar_events

interface PermissionResultCallback {
    fun onSuccess()
    fun onFailed(error: CalenderError)
}