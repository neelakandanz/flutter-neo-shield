/// Event fired when a screenshot is detected (iOS only).
///
/// On Android, screenshots are blocked silently by FLAG_SECURE and no
/// detection event is available.
class ScreenshotEvent {
  /// Creates a screenshot event with the given [timestamp].
  ScreenshotEvent({DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();

  /// The timestamp when the screenshot was detected.
  final DateTime timestamp;

  @override
  String toString() => 'ScreenshotEvent(timestamp: $timestamp)';
}

/// Event fired when screen recording state changes.
class RecordingStateEvent {
  /// Creates a recording state event.
  RecordingStateEvent({
    required this.isRecording,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Whether the screen is currently being recorded.
  final bool isRecording;

  /// The timestamp when the state change was detected.
  final DateTime timestamp;

  @override
  String toString() =>
      'RecordingStateEvent(isRecording: $isRecording, timestamp: $timestamp)';
}
