/// Security detection response types
enum SecurityMode {
  /// Strict restriction - crash or immediately prevent app execution
  strict,

  /// Log a warning to the console, allow app execution
  warn,

  /// Continue silently, handle detection programatically
  silent,

  /// Forward response to a user-provided custom callback
  custom,
}
