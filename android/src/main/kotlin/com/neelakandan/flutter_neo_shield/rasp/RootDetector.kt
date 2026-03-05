package com.neelakandan.flutter_neo_shield.rasp

import java.io.File

class RootDetector {
    fun check(): Boolean {
        // Basic Root detection by checking for su binaries
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su"
        )
        for (path in paths) {
            if (File(path).exists()) {
                return true
            }
        }
        
        // Check for test-keys build
        val buildTags = android.os.Build.TAGS
        if (buildTags != null && buildTags.contains("test-keys")) {
            return true
        }

        // Check for Magisk Manager (various package names)
        try {
            val magiskPaths = arrayOf(
                "/sbin/.magisk",
                "/cache/.disable_magisk",
                "/dev/.magisk.unblock",
                "/data/adb/magisk",
                "/data/adb/magisk.db"
            )
            for (path in magiskPaths) {
                if (File(path).exists()) {
                    return true
                }
            }
        } catch (e: Exception) {
            // Ignore permission errors
        }

        // Check if su is accessible via runtime exec
        try {
            val process = Runtime.getRuntime().exec(arrayOf("which", "su"))
            val exitCode = process.waitFor()
            if (exitCode == 0) return true
        } catch (e: Exception) {
            // Command not found or permission denied
        }

        return false
    }
}
