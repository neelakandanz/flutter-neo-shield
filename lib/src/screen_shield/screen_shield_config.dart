import 'package:flutter/material.dart';

/// Configuration for the [ScreenShield] module.
class ScreenShieldConfig {
  /// Creates a [ScreenShieldConfig] with the given options.
  const ScreenShieldConfig({
    this.enableOnInit = true,
    this.blockScreenshots = true,
    this.blockRecording = true,
    this.guardAppSwitcher = true,
    this.detectScreenshots = true,
    this.detectRecording = true,
    this.appSwitcherOverlayColor = Colors.white,
    this.appSwitcherBlurSigma = 30.0,
  });

  /// Whether to enable protection immediately on init.
  final bool enableOnInit;

  /// Whether to prevent screenshots from capturing app content.
  final bool blockScreenshots;

  /// Whether to prevent screen recording from capturing app content.
  final bool blockRecording;

  /// Whether to blur/hide content in the app switcher (recent apps).
  final bool guardAppSwitcher;

  /// Whether to listen for screenshot events (iOS only).
  final bool detectScreenshots;

  /// Whether to listen for screen recording state changes (iOS/macOS).
  final bool detectRecording;

  /// The overlay color used for app switcher guard.
  final Color appSwitcherOverlayColor;

  /// The blur intensity for app switcher guard on iOS.
  final double appSwitcherBlurSigma;

  /// Creates a copy with the given fields replaced.
  ScreenShieldConfig copyWith({
    bool? enableOnInit,
    bool? blockScreenshots,
    bool? blockRecording,
    bool? guardAppSwitcher,
    bool? detectScreenshots,
    bool? detectRecording,
    Color? appSwitcherOverlayColor,
    double? appSwitcherBlurSigma,
  }) {
    return ScreenShieldConfig(
      enableOnInit: enableOnInit ?? this.enableOnInit,
      blockScreenshots: blockScreenshots ?? this.blockScreenshots,
      blockRecording: blockRecording ?? this.blockRecording,
      guardAppSwitcher: guardAppSwitcher ?? this.guardAppSwitcher,
      detectScreenshots: detectScreenshots ?? this.detectScreenshots,
      detectRecording: detectRecording ?? this.detectRecording,
      appSwitcherOverlayColor:
          appSwitcherOverlayColor ?? this.appSwitcherOverlayColor,
      appSwitcherBlurSigma: appSwitcherBlurSigma ?? this.appSwitcherBlurSigma,
    );
  }
}
