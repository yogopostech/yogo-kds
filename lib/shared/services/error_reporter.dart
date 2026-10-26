import 'package:sentry_flutter/sentry_flutter.dart';

/// Central error reporting. Safe to call even when Sentry has no DSN /
/// isn't initialized — it just becomes a no-op, never crashes the app.
class ErrorReporter {
  static Future<void> report(Object error, [StackTrace? stack]) async {
    try {
      await Sentry.captureException(error, stackTrace: stack);
    } catch (_) {
      // reporting itself must never throw
    }
  }
}