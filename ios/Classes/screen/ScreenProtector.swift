import UIKit

/// Prevents screenshots and screen recording on iOS using the secure UITextField layer trick.
///
/// When enabled, the app's content is rendered through a layer associated with a
/// `UITextField` whose `isSecureTextEntry` is `true`. The OS treats this content
/// as DRM-protected and replaces it with a blank area during capture.
class ScreenProtector {
    private var secureField: UITextField?
    private var isEnabled = false

    /// Enable screen protection on the given window.
    func enable(in window: UIWindow?) -> Bool {
        guard let window = window, !isEnabled else { return isEnabled }

        DispatchQueue.main.async { [weak self] in
            self?.setupSecureField(in: window)
        }
        isEnabled = true
        return true
    }

    /// Disable screen protection.
    func disable() -> Bool {
        guard isEnabled else { return true }

        DispatchQueue.main.async { [weak self] in
            self?.teardownSecureField()
        }
        isEnabled = false
        return true
    }

    /// Whether screen protection is currently active.
    var isActive: Bool {
        return isEnabled
    }

    private func setupSecureField(in window: UIWindow) {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.isUserInteractionEnabled = false

        // Add field to the window hierarchy
        window.addSubview(field)
        field.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        field.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true

        // Move window's layer content into the secure field's layer.
        // The OS will blank this layer during screenshots/recordings.
        if let secureLayer = field.layer.sublayers?.first {
            secureLayer.addSublayer(window.layer)
        }

        field.layer.sublayers?.forEach { sublayer in
            sublayer.addSublayer(window.layer)
        }

        secureField = field
    }

    private func teardownSecureField() {
        guard let field = secureField else { return }

        // Restore the window layer to its original parent
        if let window = field.superview as? UIWindow {
            window.layer.removeFromSuperlayer()
            // Re-add the window's root view to trigger layout
            if let rootView = window.rootViewController?.view {
                rootView.setNeedsLayout()
            }
        }

        field.isSecureTextEntry = false
        field.removeFromSuperview()
        secureField = nil
    }
}
