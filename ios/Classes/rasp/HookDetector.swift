import Foundation
import MachO

public class HookDetector {
    public static func check() -> Bool {
        let suspiciousLibraries = [
            "Substrate",
            "cycript",
            "frida",
            "SSLKillSwitch"
        ]
        
        // Iterate through all loaded dylibs to check for hooking frameworks
        let imageCount = _dyld_image_count()
        for i in 0..<imageCount {
            if let imageName = _dyld_get_image_name(i) {
                let nameStr = String(cString: imageName).lowercased()
                for suspicious in suspiciousLibraries {
                    if nameStr.contains(suspicious.lowercased()) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
}
