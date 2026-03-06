import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../platform/screen_channel.dart';
import 'screen_shield_callback.dart';
import 'screen_shield_config.dart';

/// Prevents screenshots, screen recording, and app-switcher thumbnails
/// from capturing sensitive app content.
///
/// Uses native OS APIs:
/// - **Android:** `FLAG_SECURE` on the Activity window
/// - **iOS:** Secure UITextField layer trick + `UIScreen.isCaptured` observer
///
/// ```dart
/// // Global enable
/// FlutterNeoShield.init(
///   screenConfig: ScreenShieldConfig(blockScreenshots: true),
/// );
///
/// // Or use directly
/// await ScreenShield().enableProtection();
/// ```
class ScreenShield {
  /// Returns the singleton [ScreenShield] instance.
  factory ScreenShield() => _instance;

  ScreenShield._();

  static final ScreenShield _instance = ScreenShield._();

  ScreenShieldConfig _config = const ScreenShieldConfig();
  bool _initialized = false;
  bool _protectionActive = false;
  bool _appSwitcherActive = false;

  final _screenshotController = StreamController<ScreenshotEvent>.broadcast();
  final _recordingController =
      StreamController<RecordingStateEvent>.broadcast();

  StreamSubscription<dynamic>? _eventSubscription;

  /// Whether the shield has been initialized.
  bool get isInitialized => _initialized;

  /// The current configuration.
  ScreenShieldConfig get config => _config;

  /// Initialize the Screen Shield with the given configuration.
  ///
  /// If [ScreenShieldConfig.enableOnInit] is true, protection is
  /// automatically enabled.
  Future<void> init(ScreenShieldConfig config) async {
    _config = config;
    _initialized = true;

    _listenToNativeEvents();

    if (config.enableOnInit) {
      if (config.blockScreenshots || config.blockRecording) {
        await enableProtection();
      }
      if (config.guardAppSwitcher) {
        await enableAppSwitcherGuard();
      }
    }
  }

  /// Enable screen protection (blocks screenshots and recording).
  ///
  /// On Android, this sets `FLAG_SECURE` on the Activity window.
  /// On iOS, this uses the secure UITextField layer trick.
  ///
  /// Returns true if the protection was successfully enabled.
  Future<bool> enableProtection() async {
    final result = await ScreenChannel.enableProtection();
    _protectionActive = result;
    if (result) {
      developer.log('Screen protection enabled', name: 'ScreenShield');
    }
    return result;
  }

  /// Disable screen protection.
  ///
  /// Returns true if the protection was successfully disabled.
  Future<bool> disableProtection() async {
    final result = await ScreenChannel.disableProtection();
    if (result) {
      _protectionActive = false;
      developer.log('Screen protection disabled', name: 'ScreenShield');
    }
    return result;
  }

  /// Whether screen protection is currently active locally.
  ///
  /// For the authoritative native state, use [isProtectionActiveNative].
  bool get isProtectionActive => _protectionActive;

  /// Query the native platform for the actual protection state.
  Future<bool> get isProtectionActiveNative =>
      ScreenChannel.isProtectionActive();

  /// Enable the app switcher guard.
  ///
  /// On Android, `FLAG_SECURE` already blanks the recent-apps thumbnail.
  /// On iOS, a blur overlay is added when the app resigns active.
  Future<bool> enableAppSwitcherGuard() async {
    final result = await ScreenChannel.enableAppSwitcherGuard();
    _appSwitcherActive = result;
    return result;
  }

  /// Disable the app switcher guard.
  Future<bool> disableAppSwitcherGuard() async {
    final result = await ScreenChannel.disableAppSwitcherGuard();
    if (result) {
      _appSwitcherActive = false;
    }
    return result;
  }

  /// Whether the app switcher guard is active.
  bool get isAppSwitcherGuardActive => _appSwitcherActive;

  /// Stream of screenshot detection events.
  ///
  /// Only fires on iOS. Android blocks screenshots silently via
  /// `FLAG_SECURE` and does not provide a detection callback.
  Stream<ScreenshotEvent> get onScreenshotDetected =>
      _screenshotController.stream;

  /// Stream of recording state change events.
  ///
  /// Fires on iOS (via `UIScreen.isCaptured`) when screen recording
  /// or screen mirroring starts or stops.
  Stream<RecordingStateEvent> get onRecordingStateChanged =>
      _recordingController.stream;

  /// Query whether the screen is currently being recorded.
  Future<bool> get isScreenBeingRecorded =>
      ScreenChannel.isScreenBeingRecorded();

  void _listenToNativeEvents() {
    _eventSubscription?.cancel();
    _eventSubscription = ScreenChannel.events.listen(
      (event) {
        if (event is! Map) return;
        final type = event['type'];
        switch (type) {
          case 'screenshot':
            if (_config.detectScreenshots) {
              _screenshotController.add(ScreenshotEvent());
            }
          case 'recording':
            if (_config.detectRecording) {
              final isRecording = event['isRecording'] as bool? ?? false;
              _recordingController
                  .add(RecordingStateEvent(isRecording: isRecording));
            }
        }
      },
      onError: (Object error) {
        developer.log(
          'Screen event stream error: $error',
          name: 'ScreenShield',
        );
      },
    );
  }

  /// Dispose all resources.
  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    if (_protectionActive) {
      await disableProtection();
    }
    if (_appSwitcherActive) {
      await disableAppSwitcherGuard();
    }
  }

  /// Reset to default state. Only for testing.
  @visibleForTesting
  void reset() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    _config = const ScreenShieldConfig();
    _initialized = false;
    _protectionActive = false;
    _appSwitcherActive = false;
    ScreenChannel.resetForTesting();
  }
}
