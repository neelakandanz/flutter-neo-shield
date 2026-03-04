package com.neelakandan.flutter_neo_shield.rasp

import android.os.Debug

class DebuggerDetector {
    fun check(): Boolean {
        // Check if a debugger is currently attached
        if (Debug.isDebuggerConnected() || Debug.waitingForDebugger()) {
            return true
        }
        return false
    }
}
