// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:logger/logger.dart";

const bool isProduction = bool.fromEnvironment("dart.vm.product");

var _logger = Logger(
  level: isProduction ? Level.info : Level.debug,
  printer: PrettyPrinter(
      stackTraceBeginIndex: 1,
      methodCount: 0, // number of method calls to be displayed
      errorMethodCount: 30, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true // Should each log print contain a timestamp
      ),
);

@Deprecated('Use warn instead')
void logWarn(String tag, String message) {
  _logger.d("Tag=$tag  Message=$message");
}

@Deprecated('Use info instead')
void logInfo(String tag, String message) {
  _logger.i("Tag=$tag  Message=$message");
}

@Deprecated('Use debug instead')
void logDebug(String tag, String message) {
  _logger.w("Tag=$tag  Message=$message");
}

@Deprecated('Use error instead')
void logError(String tag, String message, {Error? error}) {
  if (!isProduction) {
    _logger.e("Tag=$tag  Message=$message", error, StackTrace.current);
    throw error ?? ArgumentError(message);
  } else {
    _logger.e("Tag=$tag  Message=$message", error);
  }
}

void debug({String? tag, Object? object, String? message}) {
  var tagStr = tag ?? '';
  if (object != null) {
    tagStr += '(${object.runtimeType.toString()})';
  }
  _logger.d('$tagStr: ${message ?? ''}');
}

void warn({String? tag, Object? object, String? message}) {
  var tagStr = tag ?? '';
  if (object != null) {
    tagStr += '(${object.runtimeType.toString()})';
  }
  _logger.w('$tagStr: ${message ?? ''}');
}

void info({String? tag, Object? object, String? message}) {
  var tagStr = tag ?? '';
  if (object != null) {
    tagStr += '(${object.runtimeType.toString()})';
  }
  _logger.i('$tagStr: ${message ?? ''}');
}

void error(
    {String? tag,
    Object? object,
    String? message,
    Object? err,
    StackTrace? trace}) {
  var tagStr = tag ?? '';
  if (object != null) {
    tagStr += '(${object.runtimeType.toString()})';
  }

  _logger.e('$tagStr: ${message ?? ''}', err, trace);
}
