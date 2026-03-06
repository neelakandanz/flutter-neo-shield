package com.neelakandan.flutter_neo_shield.screen

import android.app.Activity
import android.content.Context
import android.hardware.display.DisplayManager
import android.os.Build
import android.view.Display

/**
 * Detects whether the screen is being recorded or mirrored.
 *
 * Uses multiple strategies depending on API level:
 * - API 34+: WindowManager screen recording callback (not used here; see plugin for EventChannel)
 * - All versions: Heuristic check for virtual/presentation displays
 */
class ScreenRecordingDetector {

    /**
     * Check if screen recording or mirroring is likely active.
     *
     * Checks for virtual or presentation displays which indicate
     * MediaProjection, Chromecast, or other screen sharing.
     */
    fun isRecordingOrMirroring(activity: Activity?): Boolean {
        activity ?: return false
        return checkVirtualDisplays(activity)
    }

    @Suppress("DEPRECATION")
    private fun checkVirtualDisplays(context: Context): Boolean {
        val dm = context.getSystemService(Context.DISPLAY_SERVICE) as? DisplayManager
            ?: return false
        val displays = dm.displays ?: return false
        for (display in displays) {
            if (display.displayId != Display.DEFAULT_DISPLAY) {
                // A non-default display may indicate screen mirroring/recording
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                    val flags = display.flags
                    if (flags and Display.FLAG_PRESENTATION != 0 ||
                        flags and Display.FLAG_PRIVATE != 0
                    ) {
                        return true
                    }
                }
            }
        }
        return false
    }
}
