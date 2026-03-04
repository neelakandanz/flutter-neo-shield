import Foundation

public class JailbreakDetector {
    public static func check() -> Bool {
        // 1. Check for known jailbreak files
        let paths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]
        
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        // 2. Check sandbox violation capability
        let stringToWrite = "Jailbreak Test"
        do {
            try stringToWrite.write(toFile: "/private/jailbreak.txt", atomically: true, encoding: .utf8)
            // If we can write outside sandbox, device is jailbroken
            try? FileManager.default.removeItem(atPath: "/private/jailbreak.txt")
            return true
        } catch {
            // Write failed, which is expected on non-jailbroken
        }
        
        // 3. Check if Cydia URL scheme is available
        if let url = URL(string: "cydia://package/com.example.package") {
            if UIApplication.shared.canOpenURL(url) {
                return true
            }
        }
        
        return false
    }
}
