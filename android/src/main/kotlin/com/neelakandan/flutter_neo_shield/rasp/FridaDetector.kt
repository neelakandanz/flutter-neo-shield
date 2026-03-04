package com.neelakandan.flutter_neo_shield.rasp

import java.io.File
import java.net.Socket
import java.util.Scanner

class FridaDetector {
    fun check(): Boolean {
        // 1. Check for Frida default port (27042 is default frida-server port)
        try {
            Socket("127.0.0.1", 27042).use {
                return true
            }
        } catch (e: Exception) {
            // port not open
        }

        // 2. Scan memory maps for frida agent
        try {
            val pid = android.os.Process.myPid()
            val file = File("/proc/$pid/maps")
            if (file.exists()) {
                val scanner = Scanner(file)
                while (scanner.hasNextLine()) {
                    val line = scanner.nextLine()
                    if (line.contains("frida-agent") || line.contains("frida-gadget")) {
                        return true
                    }
                }
                scanner.close()
            }
        } catch (e: Exception) {
            // Ignore unable to read /proc/...
        }

        return false
    }
}
