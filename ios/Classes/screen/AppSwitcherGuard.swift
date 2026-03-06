import UIKit

/// Adds a blur overlay when the app enters the app switcher to prevent
/// sensitive content from being visible in the recent apps view.
///
/// Hooks into `willResignActiveNotification` and `didBecomeActiveNotification`
/// to manage the overlay lifecycle.
class AppSwitcherGuard {
    private var blurView: UIVisualEffectView?
    private var resignObserver: NSObjectProtocol?
    private var activeObserver: NSObjectProtocol?
    private var isEnabled = false

    /// The tag used to identify the blur overlay view.
    private static let blurViewTag = 999_888_777

    /// Enable the app switcher guard on the given window.
    func enable(in window: UIWindow?) {
        guard !isEnabled else { return }
        isEnabled = true

        resignObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.addBlur(to: window)
        }

        activeObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.removeBlur()
        }
    }

    /// Disable the app switcher guard.
    func disable() {
        isEnabled = false
        removeBlur()

        if let obs = resignObserver {
            NotificationCenter.default.removeObserver(obs)
            resignObserver = nil
        }
        if let obs = activeObserver {
            NotificationCenter.default.removeObserver(obs)
            activeObserver = nil
        }
    }

    var isActive: Bool {
        return isEnabled
    }

    private func addBlur(to window: UIWindow?) {
        guard let window = window else { return }
        // Don't add duplicate blur views
        guard window.viewWithTag(AppSwitcherGuard.blurViewTag) == nil else { return }

        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = window.bounds
        blurView.tag = AppSwitcherGuard.blurViewTag
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(blurView)
        self.blurView = blurView
    }

    private func removeBlur() {
        blurView?.removeFromSuperview()
        blurView = nil
    }

    deinit {
        disable()
    }
}
