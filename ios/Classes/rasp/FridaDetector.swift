import Foundation
import Darwin

public class FridaDetector {
    public static func check() -> Bool {
        // 1. Check for Frida default ports
        let fridaPorts: [in_port_t] = [27042, 27043, 4444]

        for port in fridaPorts {
            if isPortOpen(port) {
                return true
            }
        }

        // 2. Check for frida-related named pipes / files
        let fridaPaths = [
            "/usr/sbin/frida-server",
            "/usr/bin/frida-server",
            "/usr/local/bin/frida-server",
            "/usr/lib/frida",
        ]
        for path in fridaPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }

        // 3. We also check for loaded dylib "frida" in HookDetector
        // which serves as the memory scan on iOS.

        return false
    }

    private static func isPortOpen(_ port: in_port_t) -> Bool {
        let sockfd = socket(AF_INET, SOCK_STREAM, 0)
        guard sockfd != -1 else { return false }
        defer { close(sockfd) }

        // Set a short timeout so we don't block
        var timeout = timeval(tv_sec: 1, tv_usec: 0)
        setsockopt(sockfd, SOL_SOCKET, SO_SNDTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))

        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = port.bigEndian
        addr.sin_addr.s_addr = inet_addr("127.0.0.1")

        let result = withUnsafePointer(to: &addr) { addrPtr in
            addrPtr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
                connect(sockfd, sockaddrPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        return result == 0
    }
}
