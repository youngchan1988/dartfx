///
/// ProjectName: flutterhot
/// Author: youngchan
/// CreateDate: 2020/12/18 6:05 PM
/// Copyright: ©2020 NEW CORE Technology Co. Ltd. All rights reserved.
/// Description: 日志工具
///

import "package:logger/logger.dart";

const bool isProduction = bool.fromEnvironment("dart.vm.product");

var _logger = Logger(
  level: isProduction ? Level.info : Level.debug,
  printer: PrettyPrinter(
      methodCount: 0, // number of method calls to be displayed
      errorMethodCount: 30, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true // Should each log print contain a timestamp
      ),
);

void logWarn(String tag, String message) {
  _logger.d("Tag=$tag  Message=$message");
}

void logInfo(String tag, String message) {
  _logger.i("Tag=$tag  Message=$message");
}

void logDebug(String tag, String message) {
  _logger.w("Tag=$tag  Message=$message");
}

void logError(String tag, String message, {Error? error}) {
  if (!isProduction) {
    _logger.e("Tag=$tag  Message=$message", error, StackTrace.current);
    throw error ?? ArgumentError(message);
  } else {
    _logger.e("Tag=$tag  Message=$message", error);
  }
}
