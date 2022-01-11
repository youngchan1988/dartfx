///
/// Author: YoungChan
/// Date: 2021-12-30 16:39:47
/// LastEditors: YoungChan
/// LastEditTime: 2021-12-30 16:39:47
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

import 'package:dartfx/src/util/string_canonicalizer.dart';

import 'token.dart';
import 'token_constants.dart';

/// A token whose value is independent of it's type.
class StringToken extends SimpleToken {
  StringToken({
    required TokenType type,
    required dynamic value,
    int offset = 0,
  })  : valueOrLazySubstring = value,
        super(type: type, offset: offset);

  /// Creates a non-lazy string token. If [canonicalize] is true, the string
  /// is canonicalized before the token is created.
  factory StringToken.fromString(
          {required TokenType type,
          required String value,
          int charOffset = 0,
          bool canonicalize = false}) =>
      StringToken(
          type: type,
          offset: charOffset,
          value: canonicalizedString(
              value, /* start = */ 0, value.length, canonicalize));

  /// Creates a lazy string token. If [canonicalize] is true, the string
  /// is canonicalized before the token is created.
  factory StringToken.fromSubstring(
      {required TokenType type,
      required String data,
      required int start,
      required int end,
      required int charOffset,
      bool canonicalize = false}) {
    dynamic value;
    int length = end - start;
    if (length <= LAZY_THRESHOLD) {
      value = canonicalizedString(data, start, end, canonicalize);
    } else {
      value = _LazySubstring(data, start, length, canonicalize);
    }
    return StringToken(
      type: type,
      value: value,
      offset: charOffset,
    );
  }

  /// Creates a lazy string token. If [asciiOnly] is false, the byte array
  /// is passed through a UTF-8 decoder.
  factory StringToken.fromUtf8Bytes(
      {required TokenType type,
      required List<int> data,
      required int start,
      required int end,
      required bool asciiOnly,
      required int charOffset}) {
    dynamic value;
    int length = end - start;
    if (length <= LAZY_THRESHOLD) {
      value = decodeUtf8(data, start, end, asciiOnly);
    } else {
      value = _LazySubstring(data, start, length, asciiOnly);
    }
    return StringToken(type: type, value: value, offset: charOffset);
  }

  dynamic /* String | LazySubstring */ valueOrLazySubstring;

  @override
  String get lexeme {
    if (valueOrLazySubstring is String) {
      return valueOrLazySubstring;
    } else {
      assert(valueOrLazySubstring is _LazySubstring);
      dynamic data = valueOrLazySubstring.data;
      int start = valueOrLazySubstring.start;
      int end = start + (valueOrLazySubstring as _LazySubstring).length;
      if (data is String) {
        valueOrLazySubstring = canonicalizedString(
            data, start, end, valueOrLazySubstring.boolValue);
      } else {
        valueOrLazySubstring =
            decodeUtf8(data, start, end, valueOrLazySubstring.boolValue);
      }
      return valueOrLazySubstring;
    }
  }

  @override
  bool get isIdentifier => identical(kind, IDENTIFIER_TOKEN);

  @override
  String toString() => lexeme;

  static const int LAZY_THRESHOLD = 4;

  static final canonicalizer = StringCanonicalizer();

  static String canonicalizedString(
      String s, int start, int end, bool canonicalize) {
    if (!canonicalize) return s;
    return canonicalizer.canonicalize(s, start, end, /* asciiOnly = */ false);
  }

  static String decodeUtf8(List<int> data, int start, int end, bool asciiOnly) {
    return canonicalizer.canonicalize(data, start, end, asciiOnly);
  }

  @override
  Token copy() =>
      StringToken(type: type, value: valueOrLazySubstring, offset: charOffset);

  @override
  String value() => lexeme;
}

/**
 * A token whose value is independent of it's type.
 */
class SyntheticStringToken extends StringToken {
  /**
   * Initialize a newly created token to represent a token of the given [type]
   * with the given [value] at the given [offset]. If the [length] is
   * not specified, then it defaults to the length of [value].
   */
  SyntheticStringToken(
      {required TokenType type, required String value, required int offset})
      : super(type: type, value: value, offset: offset);

  @override
  Token? beforeSynthetic;

  @override
  bool get isSynthetic => true;

  @override
  Token copy() => SyntheticStringToken(
        type: type,
        value: value(),
        offset: offset,
      );
}

/// This class represents the necessary information to compute a substring
/// lazily. The substring can either originate from a string or from
/// a [:List<int>:] of UTF-8 bytes.
abstract class _LazySubstring {
  /// The original data, either a string or a List<int> */
  get data;

  int get start;
  int get length;

  /// If this substring is based on a String, the [boolValue] indicates whether
  /// the resulting substring should be canonicalized.
  ///
  /// For substrings based on a byte array, the [boolValue] is true if the
  /// array only holds ASCII characters. The resulting substring will be
  /// canonicalized after decoding.
  bool get boolValue;

  _LazySubstring.internal();

  factory _LazySubstring(data, int start, int length, bool b) {
    // See comment on [CompactLazySubstring].
    if (start < 0x100000 && length < 0x200) {
      int fields = (start << 9);
      fields = fields | length;
      fields = fields << 1;
      if (b) fields |= 1;
      return new _CompactLazySubstring(data, fields);
    } else {
      return new _FullLazySubstring(data, start, length, b);
    }
  }
}

/// This class encodes [start], [length] and [boolValue] in a single
/// 30 bit integer. It uses 20 bits for [start], which covers source files
/// of 1MB. [length] has 9 bits, which covers 512 characters.
///
/// The file html_dart2js.dart is currently around 1MB.
class _CompactLazySubstring extends _LazySubstring {
  final dynamic data;
  final int fields;

  _CompactLazySubstring(this.data, this.fields) : super.internal();

  int get start => fields >> 10;
  int get length => (fields >> 1) & 0x1ff;
  bool get boolValue => (fields & 1) == 1;
}

class _FullLazySubstring extends _LazySubstring {
  final dynamic data;
  final int start;
  final int length;
  final bool boolValue;
  _FullLazySubstring(this.data, this.start, this.length, this.boolValue)
      : super.internal();
}

bool isUserDefinableOperator(String value) {
  return isBinaryOperator(value) ||
      isMinusOperator(value) ||
      isTernaryOperator(value) ||
      isUnaryOperator(value);
}

bool isUnaryOperator(String value) => identical(value, "~");

bool isBinaryOperator(String value) {
  return identical(value, "==") ||
      identical(value, "[]") ||
      identical(value, "*") ||
      identical(value, "/") ||
      identical(value, "%") ||
      identical(value, "~/") ||
      identical(value, "+") ||
      identical(value, "<<") ||
      identical(value, ">>") ||
      identical(value, ">>>") ||
      identical(value, ">=") ||
      identical(value, ">") ||
      identical(value, "<=") ||
      identical(value, "<") ||
      identical(value, "&") ||
      identical(value, "^") ||
      identical(value, "|");
}

bool isTernaryOperator(String value) => identical(value, "[]=");

bool isMinusOperator(String value) => identical(value, "-");
