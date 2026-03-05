import Foundation
import UIKit

public class JailbreakDetector {
    public static func check() -> Bool {
        // 1. Check for known jailbreak files
        let paths = [
            "/Applications/Cydia.app",
            "/Applications/Sileo.app",
            "/Applications/Zebra.app",
            "/Applications/Substitute.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/Library/MobileSubstrate/DynamicLibraries",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/usr/bin/ssh",
            "/usr/bin/sshd",
            "/usr/libexec/sftp-server",
            "/usr/libexec/cydia",
            "/etc/apt",
            "/etc/apt/sources.list.d",
            "/private/var/lib/apt/",
            "/private/var/lib/cydia",
            "/private/var/stash",
            "/private/var/mobile/Library/SBSettings/Themes",
            "/var/cache/apt",
            "/var/lib/dpkg",
            "/var/log/syslog",
            "/var/tmp/cydia.log",
            "/private/var/mobileLibrary/SBSettingsThemes",
            "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            "/usr/lib/libjailbreak.dylib",
            "/usr/share/jailbreak/injectme.plist",
            "/private/var/checkra1n.dmg",
            "/private/var/binpack",
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

        // 3. Check if Cydia or Sileo URL schemes are available
        // UIApplication.shared is only available on the main thread;
        // wrap in a safe check to avoid crashes from background calls.
        let schemes = ["cydia://", "sileo://", "zbra://", "undecimus://", "filza://"]
        for scheme in schemes {
            if let url = URL(string: scheme) {
                // canOpenURL must be called on main thread
                if Thread.isMainThread {
                    if UIApplication.shared.canOpenURL(url) {
                        return true
                    }
                }
            }
        }

        // 4. Check for suspicious symbolic links
        let symlinks = ["/Applications", "/var/stash/Library/Ringtones", "/var/stash/Library/Wallpaper", "/var/stash/usr/include", "/var/stash/usr/libexec", "/var/stash/usr/share", "/var/stash/usr/arm-apple-darwin9"]
        for link in symlinks {
            var s = stat()
            if lstat(link, &s) == 0 {
                if (s.st_mode & S_IFLNK) == S_IFLNK {
                    return true
                }
            }
        }

        // 5. Check if we can open a writable handle outside the sandbox
        let fd = open("/private/jb_test", O_WRONLY | O_CREAT | O_TRUNC, 0o644)
        if fd != -1 {
            close(fd)
            unlink("/private/jb_test")
            return true
        }

        return false
    }
}
