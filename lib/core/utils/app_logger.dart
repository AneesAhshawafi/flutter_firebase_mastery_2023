import 'package:logger/logger.dart';

/// Centralized application logger.
///
/// Replaces all `print()` calls. Use the appropriate severity level:
/// - [AppLogger.d] — debug information
/// - [AppLogger.i] — informational messages
/// - [AppLogger.w] — warnings
/// - [AppLogger.e] — errors with optional stack traces
///
/// In release builds, the logger automatically suppresses debug/info output.
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
    level: Level.debug,
  );

  /// Log a debug message.
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log an informational message.
  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log a warning.
  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log an error with optional exception and stack trace.
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
