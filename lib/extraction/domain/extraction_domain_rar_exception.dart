/// A custom context-specific exception for RAR archive reading and extraction errors.
///
/// Implements the Exception handling specification of the project by wrapping
/// all underlying platform or parser exceptions.
class RarException implements Exception {
  /// The descriptive error message.
  final String message;

  /// The underlying cause exception, if any.
  final Object? cause;

  /// Creates a new [RarException] with the given [message] and optional [cause].
  RarException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return 'RarException: $message (Caused by: $cause)';
    }
    return 'RarException: $message';
  }
}
