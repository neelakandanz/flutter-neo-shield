package com.neelakandan.flutter_neo_shield.rasp

import android.os.Build
import java.io.File

class EmulatorDetector {
    fun check(): Boolean {
        val buildDetails = (Build.FINGERPRINT.startsWith("generic")
                || Build.FINGERPRINT.startsWith("unknown")
                || Build.MODEL.contains("google_sdk")
                || Build.MODEL.contains("Emulator")
                || Build.MODEL.contains("Android SDK built for x86")
                || Build.BOARD == "QC_Reference_Phone" //bluestacks
                || Build.MANUFACTURER.contains("Genymotion")
                || Build.HOST.startsWith("Build") //MSI App Player
                || (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
                || "google_sdk".equals(Build.PRODUCT))

        if (buildDetails) return true

        var rating = 0
        if (Build.PRODUCT.contains("sdk") ||
            Build.PRODUCT.contains("Andy") ||
            Build.PRODUCT.contains("ttVM_Hdragon") ||
            Build.PRODUCT.contains("google_sdk") ||
            Build.PRODUCT.contains("Droid4X") ||
            Build.PRODUCT.contains("nox") ||
            Build.PRODUCT.contains("sdk_x86") ||
            Build.PRODUCT.contains("sdk_google") ||
            Build.PRODUCT.contains("vbox86p") ||
            Build.PRODUCT.contains("emultor")) {
            rating++
        }
        
        if (Build.MANUFACTURER.equals("unknown") ||
            Build.MANUFACTURER.equals("Genymotion") ||
            Build.MANUFACTURER.contains("Andy") ||
            Build.MANUFACTURER.contains("MIT") ||
            Build.MANUFACTURER.contains("nox") ||
            Build.MANUFACTURER.contains("TiantianVM")){
            rating++
        }

        if (Build.BRAND.equals("generic") ||
            Build.BRAND.equals("generic_x86") ||
            Build.BRAND.equals("TiantianVM") ||
            Build.BRAND.contains("Andy")) {
            rating++
        }

        if (Build.DEVICE.contains("generic") ||
            Build.DEVICE.contains("generic_x86") ||
            Build.DEVICE.contains("Andy") ||
            Build.DEVICE.contains("ttVM_Hdragon") ||
            Build.DEVICE.contains("Droid4X") ||
            Build.DEVICE.contains("nox") ||
            Build.DEVICE.contains("generic_x86_64") ||
            Build.DEVICE.contains("vbox86p")) {
            rating++
        }

        if (Build.MODEL.equals("sdk") ||
            Build.MODEL.contains("Emulator") ||
            Build.MODEL.equals("google_sdk") ||
            Build.MODEL.contains("Droid4X") ||
            Build.MODEL.contains("TiantianVM") ||
            Build.MODEL.contains("Andy") ||
            Build.MODEL.equals("Android SDK built for x86_64") ||
            Build.MODEL.equals("Android SDK built for x86")) {
            rating++
        }

        if (Build.HARDWARE.equals("goldfish") ||
            Build.HARDWARE.equals("vbox86") ||
            Build.HARDWARE.contains("nox") ||
            Build.HARDWARE.contains("ttVM_x86")) {
            rating++
        }

        if (rating > 3) return true
        
        // Also check if goldfish properties file exists
        if (File("/dev/socket/qemud").exists() || File("/dev/qemu_pipe").exists()) {
            return true
        }

        // Check for QEMU-specific system properties
        try {
            val process = Runtime.getRuntime().exec(arrayOf("getprop", "ro.hardware.chipname"))
            val output = process.inputStream.bufferedReader().readText().trim()
            if (output.contains("ranchu") || output.contains("goldfish")) {
                return true
            }
        } catch (e: Exception) {
            // Ignore
        }

        return false
    }
}
