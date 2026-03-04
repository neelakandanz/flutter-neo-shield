package com.neelakandan.flutter_neo_shield.rasp

import android.content.Context
import android.content.pm.ApplicationInfo

class IntegrityDetector {
    fun check(context: Context): Boolean {
        // 1. Check if application is debuggable (tampered APKs often are)
        val isDebuggable = (0 != (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE))
        if (isDebuggable) {
            return true
        }

        // 2. Check installer package name
        // Allowed stores: Play Store, Amazon, Samsung, Huawei, etc.
        val allowedInstallers = listOf(
            "com.android.vending",
            "com.amazon.venezia",
            "com.sec.android.app.samsungapps",
            "com.huawei.appmarket"
        )
        
        try {
            val installer = context.packageManager.getInstallerPackageName(context.packageName)
            // If installer is null, it was sideloaded. We might not want to flag all sideloaded apps as tampered
            // But if it's a known malicious installer or a tool like Lucky Patcher, flag it.
            if (installer != null && installer == "com.android.vending.billing.InAppBillingService.LUCK") {
                return true
            }
        } catch (e: Exception) {
            // ignore
        }

        return false
    }
}
