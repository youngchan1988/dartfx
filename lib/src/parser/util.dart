// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Modified by the dartfx project authors.
// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/lexer/tokens/token.dart';

import '../messages/codes.dart' show noLength;

/// Returns true if [token] is the symbol or keyword [value].
bool optional(String value, Token token) {
  return identical(value, token.toString());
}

/// Returns the token before the close brace, bracket, or parenthesis
/// associated with [left]. For '<', it may return `null`.
Token? beforeCloseBraceTokenFor(BeginToken left) {
  Token? endToken = left.endToken;
  if (endToken == null) {
    return null;
  }
  Token token = left;
  Token next = token.next!;
  while (next != endToken && next != next.next) {
    token = next;
    next = token.next!;
  }
  return token;
}

/// Return [token] or a token before [token] which is either
/// not synthetic or synthetic with non-zero length.
Token findPreviousNonZeroLengthToken(Token token) {
  while (token.isSynthetic && token.length == 0) {
    Token? previous = token.beforeSynthetic;
    if (previous == token) {
      throw StateError("token == token.beforeSynthetic");
    }
    if (previous == null) {
      break;
    }
    token = previous;
  }
  return token;
}

/// Return [token] or a token after [token] which is either
/// not synthetic or synthetic with non-zero length.
/// This may return EOF if there are no more non-synthetic tokens in the stream.
Token findNonZeroLengthToken(Token token) {
  while (token.length == 0 && !token.isEof) {
    token = token.next!;
  }
  return token;
}

bool isDigit(int c) => c >= 0x30 && c <= 0x39;

bool isLetter(int c) => c >= 0x41 && c <= 0x5A || c >= 0x61 && c <= 0x7A;

bool isLetterOrDigit(int c) => isLetter(c) || isDigit(c);

bool isWhitespace(int c) => c == 0x20 || c == 0xA || c == 0xD || c == 0x9;

/// Return true if the given token matches one of the given values.
bool isOneOf(Token token, Iterable<String> values) {
  for (String tokenValue in values) {
    if (optional(tokenValue, token)) {
      return true;
    }
  }
  return false;
}

/// Return true if the given token matches one of the given values or is EOF.
bool isOneOfOrEof(Token token, Iterable<String> values) {
  for (String tokenValue in values) {
    if (optional(tokenValue, token)) {
      return true;
    }
  }
  return token.isEof;
}

/// A null-aware alternative to `token.length`.  If [token] is `null`, returns
/// [noLength].
int lengthForToken(Token? token) {
  return token == null ? noLength : token.length;
}

/// Returns the length of the span from [begin] to [end] (inclusive). If both
/// tokens are null, return [noLength]. If one of the tokens are null, return
/// the length of the other token.
int lengthOfSpan(Token? begin, Token? end) {
  if (begin == null) return lengthForToken(end);
  if (end == null) return lengthForToken(begin);
  return end.offset + end.length - begin.offset;
}

/// Split `>=` into two separate tokens.
/// Call [Token.setNext] to add the token to the stream.
Token splitGtEq(Token token) {
  assert(optional('>=', token));
  return SimpleToken(type: TokenType.GT, offset: token.charOffset)
    ..setNext(SimpleToken(type: TokenType.EQ, offset: token.charOffset + 1)
      // Set next rather than calling Token.setNext
      // so that the previous token is not set.
      ..next = token.next);
}

/// Split `>>` into two separate tokens.
/// Call [Token.setNext] to add the token to the stream.
SimpleToken splitGtGt(Token token) {
  assert(optional('>>', token));
  return SimpleToken(type: TokenType.GT, offset: token.charOffset)
    ..setNext(SimpleToken(type: TokenType.GT, offset: token.charOffset + 1)
      // Set next rather than calling Token.setNext
      // so that the previous token is not set.
      ..next = token.next);
}

/// Split `>>=` into three separate tokens.
/// Call [Token.setNext] to add the token to the stream.
Token splitGtGtEq(Token token) {
  assert(optional('>>=', token));
  return SimpleToken(
    type: TokenType.GT,
    offset: token.charOffset,
  )..setNext(SimpleToken(type: TokenType.GT, offset: token.charOffset + 1)
    ..setNext(SimpleToken(type: TokenType.EQ, offset: token.charOffset + 2)
      // Set next rather than calling Token.setNext
      // so that the previous token is not set.
      ..next = token.next));
}

/// Split `>>=` into two separate tokens... `>` followed by `>=`.
/// Call [Token.setNext] to add the token to the stream.
Token splitGtFromGtGtEq(Token token) {
  assert(optional('>>=', token));
  return SimpleToken(type: TokenType.GT, offset: token.charOffset)
    ..setNext(SimpleToken(type: TokenType.GT_EQ, offset: token.charOffset + 1)
      // Set next rather than calling Token.setNext
      // so that the previous token is not set.
      ..next = token.next);
}

/// Split `>>>` into two separate tokens... `>` followed by `>>`.
/// Call [Token.setNext] to add the token to the stream.
Token splitGtFromGtGtGt(Token token) {
  assert(optional('>>>', token));
  return SimpleToken(
    type: TokenType.GT,
    offset: token.charOffset,
  )..setNext(SimpleToken(type: TokenType.GT_GT, offset: token.charOffset + 1)
    // Set next rather than calling Token.setNext
    // so that the previous token is not set.
    ..next = token.next);
}

/// Split `>>>=` into two separate tokens... `>` followed by `>>=`.
/// Call [Token.setNext] to add the token to the stream.
Token splitGtFromGtGtGtEq(Token token) {
  assert(optional('>>>=', token));
  return SimpleToken(
    type: TokenType.GT,
    offset: token.charOffset,
  )..setNext(SimpleToken(type: TokenType.GT_GT_EQ, offset: token.charOffset + 1)
    // Set next rather than calling Token.setNext
    // so that the previous token is not set.
    ..next = token.next);
}
