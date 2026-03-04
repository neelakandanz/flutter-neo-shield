import Foundation

public class EmulatorDetector {
    public static func check() -> Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            // Fallback runtime checks if macro fails
            // Check for simulator-specific paths or environment variables
            if ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil {
                return true
            }
            if ProcessInfo.processInfo.environment["SIMULATOR_HOST_HOME"] != nil {
                return true
            }
            
            var name = [Int32](repeating: 0, count: 2)
            name[0] = CTL_HW
            name[1] = HW_MACHINE
            var size = Int()
            sysctl(UnsafeMutablePointer<Int32>(mutating: name), 2, nil, &size, nil, 0)
            var machine = [CChar](repeating: 0, count: size)
            sysctl(UnsafeMutablePointer<Int32>(mutating: name), 2, &machine, &size, nil, 0)
            let platform = String(cString: machine)
            
            if platform == "i386" || platform == "x86_64" {
                return true
            }
            
            return false
        #endif
    }
}
