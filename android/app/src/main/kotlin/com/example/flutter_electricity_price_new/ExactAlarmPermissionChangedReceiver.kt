package com.example.flutter_precioluz_new

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 * Optional receiver to observe changes to SCHEDULE_EXACT_ALARM permission.
 * Google recommends observing ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED.
 */
class ExactAlarmPermissionChangedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if ("android.app.action.SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED" == intent?.action) {
                Log.d("ExactAlarm", "Exact alarm permission state changed")
                // In a fuller implementation, you could forward this to Flutter via
                // a dedicated EventChannel or re-check permission state here.
            }
        }
    }
}

