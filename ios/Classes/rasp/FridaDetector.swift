import Foundation
import Darwin

public class FridaDetector {
    public static func check() -> Bool {
        // 1. Check for Frida default port (27042 is default frida-server port)
        // iOS doesn't easily let us probe local ports due to sandbox, but we can try to connect
        var sockfd = socket(AF_INET, SOCK_STREAM, 0)
        if sockfd != -1 {
            var addr = sockaddr_in()
            addr.sin_family = sa_family_t(AF_INET)
            addr.sin_port = in_port_t(27042).bigEndian
            addr.sin_addr.s_addr = inet_addr("127.0.0.1")
            
            let addrPointer = withUnsafePointer(to: &addr) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { $0 }
            }
            
            let result = connect(sockfd, addrPointer, socklen_t(MemoryLayout<sockaddr_in>.size))
            close(sockfd)
            
            if result == 0 {
                // Connection successful, meaning something is listening on that port
                return true
            }
        }
        
        // 2. We already check for loaded dylib "frida" in HookDetector which serves as the memory scan on iOS.
        
        return false
    }
}
