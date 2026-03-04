import Flutter
import UIKit

/// FlutterNeoShieldPlugin — iOS platform implementation.
///
/// Provides native memory allocation and secure wipe operations
/// for the Memory Shield module.
public class FlutterNeoShieldPlugin: NSObject, FlutterPlugin {
    private var secureStorage: [String: Data] = [:]

    public static func register(with registrar: FlutterPluginRegistrar) {
        let memoryChannel = FlutterMethodChannel(
            name: "com.neelakandan.flutter_neo_shield/memory",
            binaryMessenger: registrar.messenger()
        )
        let raspChannel = FlutterMethodChannel(
            name: "com.neelakandan.flutter_neo_shield/rasp",
            binaryMessenger: registrar.messenger()
        )
        let instance = FlutterNeoShieldPlugin()
        registrar.addMethodCallDelegate(instance, channel: memoryChannel)
        registrar.addMethodCallDelegate(instance, channel: raspChannel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            if call.method == "wipeAll" {
                wipeAll()
                result(nil)
                return
            }
            result(FlutterError(code: "INVALID_ARGS", message: "Arguments required", details: nil))
            return
        }

        switch call.method {
        case "allocateSecure":
            guard let id = args["id"] as? String,
                  let data = args["data"] as? FlutterStandardTypedData else {
                result(FlutterError(code: "INVALID_ARGS", message: "id and data required", details: nil))
                return
            }
            secureStorage[id] = Data(data.data)
            result(nil)

        case "readSecure":
            guard let id = args["id"] as? String,
                  let data = secureStorage[id] else {
                result(FlutterError(code: "NOT_FOUND", message: "No secure data found", details: nil))
                return
            }
            result(FlutterStandardTypedData(bytes: data))

        case "wipeSecure":
            guard let id = args["id"] as? String else {
                result(nil)
                return
            }
            if var data = secureStorage[id] {
                data.resetBytes(in: 0..<data.count)
                secureStorage.removeValue(forKey: id)
            }
            result(nil)

        case "wipeAll":
            wipeAll()
            result(nil)

        // RASP Shield
        case "checkDebugger":
            result(DebuggerDetector.check())
            
        case "checkRoot":
            result(JailbreakDetector.check())

        case "checkEmulator":
            result(EmulatorDetector.check())

        case "checkHooks":
            result(HookDetector.check())

        case "checkFrida":
            result(FridaDetector.check())

        case "checkIntegrity":
            result(IntegrityDetector.check())
        
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func wipeAll() {
        for key in secureStorage.keys {
            if var data = secureStorage[key] {
                data.resetBytes(in: 0..<data.count)
            }
        }
        secureStorage.removeAll()
    }
}
