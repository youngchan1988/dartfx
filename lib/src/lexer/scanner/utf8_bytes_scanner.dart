// Copyright (c) 2013, the Dart project authors. Please see the AUTHORS file
// for details (https://github.com/dart-lang/sdk/blob/main/AUTHORS). All rights
//reserved. Use of this source code is governed by a BSD-style license that can
// be found in the LICENSE file.

// Modified by the dartfx project authors.
// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'package:dartfx/src/lexer/tokens/string_token.dart';
import 'package:dartfx/src/lexer/tokens/token.dart';
import 'scanner.dart';

class Utf8BytesScanner extends Scanner {
  Utf8BytesScanner({required this.bytes}) : super();

  /// The file content.
  ///
  /// The content is zero-terminated.
  final List<int> bytes;

  /// Points to the offset of the last byte returned by [advance].
  ///
  /// After invoking [currentAsUnicode], the [byteOffset] points to the last
  /// byte that is part of the (unicode or ASCII) character. That way, [advance]
  /// can always increase the byte offset by 1.
  int byteOffset = -1;

  /// The getter [scanOffset] is expected to return the index where the current
  /// character *starts*. In case of a non-ascii character, after invoking
  /// [currentAsUnicode], the byte offset points to the *last* byte.
  ///
  /// This field keeps track of the number of bytes for the current unicode
  /// character. For example, if bytes 7,8,9 encode one unicode character, the
  /// [byteOffset] is 9 (after invoking [currentAsUnicode]). The [scanSlack]
  /// will be 2, so that [scanOffset] returns 7.
  int scanSlack = 0;

  /// Holds the [byteOffset] value for which the current [scanSlack] is valid.
  int scanSlackOffset = -1;

  /// The difference between the number of bytes and the number of corresponding
  /// string characters, up to the current [byteOffset].
  int utf8Slack = 0;

  bool containsBomAt(int offset) {
    const List<int> BOM_UTF8 = const [0xEF, 0xBB, 0xBF];

    return offset + 3 < bytes.length &&
        bytes[offset] == BOM_UTF8[0] &&
        bytes[offset + 1] == BOM_UTF8[1] &&
        bytes[offset + 2] == BOM_UTF8[2];
  }

  /// Returns the unicode code point starting at the byte offset [startOffset]
  /// with the byte [nextByte].
  int nextCodePoint(int startOffset, int nextByte) {
    int expectedHighBytes;
    if (nextByte < 0xC2) {
      expectedHighBytes = 1; // Bad code unit.
    } else if (nextByte < 0xE0) {
      expectedHighBytes = 2;
    } else if (nextByte < 0xF0) {
      expectedHighBytes = 3;
    } else if (nextByte < 0xF5) {
      expectedHighBytes = 4;
    } else {
      expectedHighBytes = 1; // Bad code unit.
    }
    int numBytes = 0;
    for (int i = 0; i < expectedHighBytes; i++) {
      if (bytes[byteOffset + i] < 0x80) {
        break;
      }
      numBytes++;
    }
    int end = startOffset + numBytes;
    byteOffset = end - 1;
    if (expectedHighBytes == 1 || numBytes != expectedHighBytes) {
      return unicodeReplacementCharacterRune;
    }
    // TODO(lry): measurably slow, decode creates first a Utf8Decoder and a
    // _Utf8Decoder instance. Also the sublist is eagerly allocated.
    String codePoint =
        utf8.decode(bytes.sublist(startOffset, end), allowMalformed: true);
    if (codePoint.length == 0) {
      // The UTF-8 decoder discards leading BOM characters.
      // TODO(floitsch): don't just assume that removed characters were the
      // BOM.
      assert(containsBomAt(startOffset));
      codePoint = String.fromCharCode(unicodeBomCharacterRune);
    }
    if (codePoint.length == 1) {
      utf8Slack += (numBytes - 1);
      scanSlack = numBytes - 1;
      scanSlackOffset = byteOffset;
      return codePoint.codeUnitAt(/* index = */ 0);
    } else if (codePoint.length == 2) {
      utf8Slack += (numBytes - 2);
      scanSlack = numBytes - 1;
      scanSlackOffset = byteOffset;
      stringOffsetSlackOffset = byteOffset;
      // In case of a surrogate pair, return a single code point.
      // Gracefully degrade given invalid UTF-8.
      RuneIterator runes = codePoint.runes.iterator;
      if (!runes.moveNext()) return unicodeReplacementCharacterRune;
      int codeUnit = runes.current;
      return !runes.moveNext() ? codeUnit : unicodeReplacementCharacterRune;
    } else {
      return unicodeReplacementCharacterRune;
    }
  }

  int lastUnicodeOffset = -1;

  /// This field remembers the byte offset of the last character decoded with
  /// [nextCodePoint] that used two code units in UTF-16.
  ///
  /// [nextCodePoint] returns a single code point for each unicode character,
  /// even if it needs two code units in UTF-16.
  ///
  /// For example, '\u{1d11e}' uses 4 bytes in UTF-8, and two code units in
  /// UTF-16. The [utf8Slack] is therefore 2. After invoking [nextCodePoint], the
  /// [byteOffset] points to the last (of 4) bytes. The [stringOffset] should
  /// return the offset of the first one, which is one position more left than
  /// the [utf8Slack].
  int stringOffsetSlackOffset = -1;

  @override
  int advance() => bytes[++byteOffset];

  @override
  int peek() => bytes[byteOffset + 1];

  @override
  bool get atEndOfSource => byteOffset >= bytes.length - 1;

  @override
  Scanner createRecoveryOptionScanner() {
    var scanner = Utf8BytesScanner(bytes: bytes);
    scanner.recoveryOptionScanner(this);
    scanner.byteOffset = byteOffset;
    scanner.scanSlack = scanSlack;
    scanner.scanSlackOffset = scanSlackOffset;
    scanner.utf8Slack = utf8Slack;
    return scanner;
  }

  @override
  StringToken createSubstringToken(TokenType type, int start, bool asciiOnly,
      [int extraOffset = 0]) {
    return StringToken.fromUtf8Bytes(
        type: type,
        data: bytes,
        start: start,
        end: byteOffset + extraOffset,
        asciiOnly: asciiOnly,
        charOffset: tokenStart);
  }

  @override
  int currentAsUnicode(int next) {
    if (next < 128) return next;
    // Check if currentAsUnicode was already invoked.
    if (byteOffset == lastUnicodeOffset) return next;
    int res = nextCodePoint(byteOffset, next);
    lastUnicodeOffset = byteOffset;
    return res;
  }

  @override
  void handleUnicode(int startScanOffset) {
    int end = byteOffset;
    // TODO(lry): this measurably slows down the scanner for files with unicode.
    String s =
        utf8.decode(bytes.sublist(startScanOffset, end), allowMalformed: true);
    utf8Slack += (end - startScanOffset) - s.length;
  }

  /// Returns the byte offset of the first byte that belongs to the current
  /// character.
  @override
  int get scanOffset {
    if (byteOffset == scanSlackOffset) {
      return byteOffset - scanSlack;
    } else {
      return byteOffset;
    }
  }

  @override
  int get stringOffset {
    if (stringOffsetSlackOffset == byteOffset) {
      return byteOffset - utf8Slack - 1;
    } else {
      return byteOffset - utf8Slack;
    }
  }
}
