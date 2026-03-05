import Foundation
import MachO

public class HookDetector {
    public static func check() -> Bool {
        let suspiciousLibraries = [
            "substrate",
            "cycript",
            "frida",
            "fridagadget",
            "sslkillswitch",
            "sslkillswitch2",
            "mobilesubstrate",
            "substrateinserter",
            "substrateloader",
            "substratebootstrap",
            "libcycript",
            "libjailbreak",
            "substitute",
            "cephei",
            "rocketbootstrap",
            "colorpicker",
            "snoolie",
            "shadow",
            "liberty",
            "choicy",
        ]

        // Iterate through all loaded dylibs to check for hooking frameworks
        let imageCount = _dyld_image_count()
        for i in 0..<imageCount {
            if let imageName = _dyld_get_image_name(i) {
                let nameStr = String(cString: imageName).lowercased()
                for suspicious in suspiciousLibraries {
                    if nameStr.contains(suspicious) {
                        return true
                    }
                }
            }
        }

        return false
    }
}
