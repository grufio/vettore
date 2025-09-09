import 'dart:developer' as dev;

void logWarn(String message, [Object? error, StackTrace? stackTrace]) {
  dev.log(message,
      name: 'vettore', level: 900, error: error, stackTrace: stackTrace);
}
