package com.neelakandan.flutter_neo_shield.rasp

import android.content.Context
import android.content.pm.PackageManager
import java.lang.reflect.Modifier

class HookDetector {
    fun check(context: Context): Boolean {
        // 1. Check for installed hook packages
        val hookPackages = arrayOf(
            "de.robv.android.xposed.installer",
            "com.saurik.substrate",
            "org.lsposed.lsposed",
            "top.johnwu.magisk",
            "org.lsposed.manager",
            "io.github.lsposed.manager",
            "com.topjohnwu.magisk",
            "me.weishu.exp",
            "com.formyhm.hideroot",
            "com.amphoras.hidemyroot"
        )
        val pm = context.packageManager
        for (pkg in hookPackages) {
            try {
                pm.getPackageInfo(pkg, PackageManager.GET_META_DATA)
                return true
            } catch (e: PackageManager.NameNotFoundException) {
                // not installed
            }
        }
        
        // 2. Check for Xposed classes loaded in memory
        try {
            val hasXposed = Class.forName("de.robv.android.xposed.XposedBridge") != null
            if (hasXposed) return true
        } catch (e: ClassNotFoundException) {
            // expected
        }

        // 3. Inspect stack traces for hooking frameworks
        try {
            throw Exception()
        } catch (e: Exception) {
            for (element in e.stackTrace) {
                if (element.className.contains("xposed") ||
                    element.className.contains("com.saurik.substrate") ||
                    element.className.contains("LSPosed") 
                ) {
                    return true
                }
            }
        }

        return false
    }
}
