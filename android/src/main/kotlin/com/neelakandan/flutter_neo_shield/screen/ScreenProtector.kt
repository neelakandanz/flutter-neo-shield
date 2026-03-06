package com.neelakandan.flutter_neo_shield.screen

import android.app.Activity
import android.view.WindowManager

/**
 * Prevents screenshots and screen recording by setting FLAG_SECURE on the Activity window.
 *
 * FLAG_SECURE causes the OS to render a black screen for:
 * - Screenshots (including adb screencap on stock Android)
 * - Screen recording (MediaProjection API)
 * - Chromecast / screen mirroring
 * - App switcher (recent apps) thumbnails
 */
class ScreenProtector {

    fun enable(activity: Activity?): Boolean {
        activity ?: return false
        activity.runOnUiThread {
            activity.window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            )
        }
        return true
    }

    fun disable(activity: Activity?): Boolean {
        activity ?: return false
        activity.runOnUiThread {
            activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
        return true
    }

    fun isActive(activity: Activity?): Boolean {
        activity ?: return false
        val flags = activity.window?.attributes?.flags ?: 0
        return flags and WindowManager.LayoutParams.FLAG_SECURE != 0
    }
}
