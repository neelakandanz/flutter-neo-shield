import UIKit

/// Detects when the user takes a screenshot (iOS 7+).
///
/// The notification fires AFTER the screenshot is taken. Combined with
/// ScreenProtector, the captured content will already be blanked.
class ScreenshotDetector {
    private var observer: NSObjectProtocol?
    private var handler: (() -> Void)?

    /// Start detecting screenshots.
    func startDetecting(handler: @escaping () -> Void) {
        stopDetecting()
        self.handler = handler
        observer = NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handler?()
        }
    }

    /// Stop detecting screenshots.
    func stopDetecting() {
        if let obs = observer {
            NotificationCenter.default.removeObserver(obs)
            observer = nil
        }
        handler = nil
    }

    deinit {
        stopDetecting()
    }
}
