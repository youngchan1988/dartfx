// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details (https://github.com/dart-lang/sdk/blob/main/AUTHORS). All rights
//reserved. Use of this source code is governed by a BSD-style license that can
// be found in the LICENSE file.

// Modified by the dartfx project authors.
// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: constant_identifier_names, sort_constructors_first

import 'package:dartfx/src/ast/syntactic_entity.dart';

import 'comment_token.dart';
import 'keyword_token.dart';
import 'token_constants.dart';

const int NO_PRECEDENCE = 0;
const int ASSIGNMENT_PRECEDENCE = 1;
const int CASCADE_PRECEDENCE = 2;
const int CONDITIONAL_PRECEDENCE = 3;
const int IF_NULL_PRECEDENCE = 4;
const int LOGICAL_OR_PRECEDENCE = 5;
const int LOGICAL_AND_PRECEDENCE = 6;
const int EQUALITY_PRECEDENCE = 7;
const int RELATIONAL_PRECEDENCE = 8;
const int BITWISE_OR_PRECEDENCE = 9;
const int BITWISE_XOR_PRECEDENCE = 10;
const int BITWISE_AND_PRECEDENCE = 11;
const int SHIFT_PRECEDENCE = 12;
const int ADDITIVE_PRECEDENCE = 13;
const int MULTIPLICATIVE_PRECEDENCE = 14;
const int PREFIX_PRECEDENCE = 15;
const int POSTFIX_PRECEDENCE = 16;
const int SELECTOR_PRECEDENCE = 17;

abstract class Token implements SyntacticEntity {
  /// Return `true` if this token represents an end of file.
  bool get isEof;

  /// True if this token is an identifier. Some keywords allowed as identifiers,
  /// see implementation in [KeywordToken].
  bool get isIdentifier;

  /// True if this token is a keyword. Some keywords allowed as identifiers,
  /// see implementation in [KeywordToken].
  bool get isKeyword;

  /// True if this token is a keyword or an identifier.
  bool get isKeywordOrIdentifier;

  /// Return `true` if this token represents an operator.
  bool get isOperator;

  /// Return the lexeme that represents this token.
  ///
  /// For [StringToken]s the [lexeme] includes the quotes, explicit escapes, etc.
  String get lexeme;

  /// Return the next token in the token stream.
  Token? get next;

  /// Return the previous token in the token stream.
  Token? get previous;

  /// The character offset of the start of this token within the source text.
  int get charOffset;

  /// The character offset of the end of this token within the source text.
  int get charEnd;

  /// The kind enum of this token as determined by its [type].
  int get kind;

  /// Return `true` if this token is a synthetic token. A synthetic token is a
  /// token that was introduced by the parser in order to recover from an error
  /// in the code.
  bool get isSynthetic;

  /// Return the type of the token.
  TokenType get type;

  /// Return the first comment in the list of comments that precede this token,
  /// or `null` if there are no comments preceding this token. Additional
  /// comments can be reached by following the token stream using [next] until
  /// `null` is returned.
  ///
  /// For example, if the original contents were `/* one */ /* two */ id`, then
  /// the first preceding comment token will have a lexeme of `/* one */` and
  /// the next comment token will have a lexeme of `/* two */`.
  CommentToken? get precedingComments;

  /// The token that corresponds to this token, or `null` if this token is not
  /// the first of a pair of matching tokens (such as parentheses).
  Token? get endGroup => null;

  /// The token before this synthetic token,
  /// or `null` if this is not a synthetic `)`, `]`, `}`, or `>` token.
  Token? get beforeSynthetic;

  /// Set token before this synthetic `)`, `]`, `}`, or `>` token,
  /// and ignored otherwise.
  set beforeSynthetic(Token? previous);

  /// Set the next token in the token stream to the given [token]. This has the
  /// side-effect of setting this token to be the previous token for the given
  /// token. Return the token that was passed in.
  Token setNext(Token token);

  /// Set the next token in the token stream to the given token without changing
  /// which token is the previous token for the given token. Return the token
  /// that was passed in.
  Token? setNextWithoutSettingPrevious(Token? token);

  /// Return the next token in the token stream.
  set next(Token? next);

  /// Set the previous token in the token stream to the given [token].
  set previous(Token? token);

  set offset(int offset);

  /// Return a newly created token that is a copy of this tokens
  /// including any [preceedingComment] tokens,
  /// but that is not a part of any token stream.
  Token copy();

  /// Copy a linked list of comment tokens identical to the given comment tokens.
  CommentToken? copyComments(CommentToken? token);

  /// Return the value of this token. For keyword tokens, this is the keyword
  /// associated with the token, for other tokens it is the lexeme associated
  /// with the token.
  Object value();

  /// Return `true` if this token has any one of the given [types].
  bool matchesAny(List<TokenType> types);

  /// Compare the given tokens to find the token that appears first in the
  /// source being parsed. That is, return the left-most of all of the tokens.
  /// Return the token with the smallest offset, or `null` if all of the
  /// tokens are `null`.
  static Token? lexicallyFirst([Token? t1, Token? t2, Token? t3, Token? t4]) {
    Token? result = t1;
    if (result == null || t2 != null && t2.charOffset < result.charOffset) {
      result = t2;
    }
    if (result == null || t3 != null && t3.charOffset < result.charOffset) {
      result = t3;
    }
    if (result == null || t4 != null && t4.charOffset < result.charOffset) {
      result = t4;
    }
    return result;
  }
}

class SimpleToken extends Token {
  SimpleToken({required this.type, int offset = 0}) : _offset = offset;

  factory SimpleToken.eof(int offset) {
    var eof = SimpleToken(type: TokenType.EOF, offset: offset);
    eof.previous = eof;
    eof.next = eof;
    return eof;
  }

  int _offset;

  @override
  Token? get beforeSynthetic => null;

  @override
  set beforeSynthetic(Token? previous) {
    // ignored
  }

  /// The first comment in the list of comments that precede this token.
  CommentToken? _precedingComment;

  @override
  bool get isSynthetic => length == 0;

  @override
  int get charEnd => charOffset + length;

  @override
  int get charOffset => _offset;

  @override
  bool get isEof => type == TokenType.EOF;

  @override
  bool get isIdentifier => false;

  @override
  bool get isKeyword => false;

  @override
  bool get isKeywordOrIdentifier => isIdentifier;

  @override
  bool get isOperator => type.isOperator;

  @override
  int get length => lexeme.length;

  @override
  String get lexeme => type.lexeme;

  @override
  CommentToken? get precedingComments => _precedingComment;

  set precedingComments(CommentToken? comment) {
    _precedingComment = comment;
    _setCommentParent(_precedingComment);
  }

  @override
  Token? next;

  @override
  Token? previous;

  @override
  int get kind => type.kind;

  @override
  final TokenType type;

  @override
  Token copy() => SimpleToken(type: type, offset: _offset);

  @override
  CommentToken? copyComments(CommentToken? token) {
    if (token == null) {
      return null;
    }
    CommentToken head = token.copy();
    Token tail = head;
    token = token.next as CommentToken?;
    while (token != null) {
      tail = tail.setNext(token.copy());
      token = token.next as CommentToken?;
    }
    return head;
  }

  @override
  bool matchesAny(List<TokenType> types) {
    for (TokenType type in types) {
      if (this.type == type) {
        return true;
      }
    }
    return false;
  }

  @override
  Token setNext(Token token) {
    next = token;
    token.previous = this;
    return token;
  }

  @override
  Token? setNextWithoutSettingPrevious(Token? token) {
    next = token;
    return token;
  }

  @override
  String toString() => lexeme;

  @override
  Object value() => lexeme;

  @override
  int get end => offset + length;

  @override
  int get offset => _offset;

  @override
  set offset(int offset) {
    _offset = offset;
  }

  /// Sets the `parent` property to `this` for the given [comment] and all the
  /// next tokens.
  void _setCommentParent(CommentToken? comment) {
    while (comment != null) {
      comment.parent = this;
      comment = comment.next as CommentToken?;
    }
  }
}

/// The opening half of a grouping pair of tokens. This is used for curly
/// brackets ('{'), parentheses ('('), and square brackets ('[').
class BeginToken extends SimpleToken {
  /// The token that corresponds to this token.
  Token? endToken;

  /// Initialize a newly created token to have the given [type] at the given
  /// [offset].
  BeginToken({required TokenType type, int offset = 0})
      : super(type: type, offset: offset) {
    assert(type == TokenType.LT ||
        type == TokenType.OPEN_CURLY_BRACKET ||
        type == TokenType.OPEN_PAREN ||
        type == TokenType.OPEN_SQUARE_BRACKET ||
        type == TokenType.STRING_INTERPOLATION_EXPRESSION);
  }

  @override
  Token copy() => BeginToken(type: type, offset: _offset);

  @override
  Token? get endGroup => endToken;

  /// Set the token that corresponds to this token.
  set endGroup(Token? token) {
    endToken = token;
  }
}

/// The classes (or groups) of tokens with a similar use.
class TokenClass {
  /// A value used to indicate that the token type is not part of any specific
  /// class of token.
  static const TokenClass NO_CLASS = TokenClass('NO_CLASS');

  /// A value used to indicate that the token type is an additive operator.
  static const TokenClass ADDITIVE_OPERATOR =
      TokenClass('ADDITIVE_OPERATOR', ADDITIVE_PRECEDENCE);

  /// A value used to indicate that the token type is an assignment operator.
  static const TokenClass ASSIGNMENT_OPERATOR =
      TokenClass('ASSIGNMENT_OPERATOR', ASSIGNMENT_PRECEDENCE);

  /// A value used to indicate that the token type is a bitwise-and operator.
  static const TokenClass BITWISE_AND_OPERATOR =
      TokenClass('BITWISE_AND_OPERATOR', BITWISE_AND_PRECEDENCE);

  /// A value used to indicate that the token type is a bitwise-or operator.
  static const TokenClass BITWISE_OR_OPERATOR =
      TokenClass('BITWISE_OR_OPERATOR', BITWISE_OR_PRECEDENCE);

  /// A value used to indicate that the token type is a bitwise-xor operator.
  static const TokenClass BITWISE_XOR_OPERATOR =
      TokenClass('BITWISE_XOR_OPERATOR', BITWISE_XOR_PRECEDENCE);

  /// A value used to indicate that the token type is a cascade operator.
  static const TokenClass CASCADE_OPERATOR =
      TokenClass('CASCADE_OPERATOR', CASCADE_PRECEDENCE);

  /// A value used to indicate that the token type is a conditional operator.
  static const TokenClass CONDITIONAL_OPERATOR =
      TokenClass('CONDITIONAL_OPERATOR', CONDITIONAL_PRECEDENCE);

  /// A value used to indicate that the token type is an equality operator.
  static const TokenClass EQUALITY_OPERATOR =
      TokenClass('EQUALITY_OPERATOR', EQUALITY_PRECEDENCE);

  /// A value used to indicate that the token type is an if-null operator.
  static const TokenClass IF_NULL_OPERATOR =
      TokenClass('IF_NULL_OPERATOR', IF_NULL_PRECEDENCE);

  /// A value used to indicate that the token type is a logical-and operator.
  static const TokenClass LOGICAL_AND_OPERATOR =
      TokenClass('LOGICAL_AND_OPERATOR', LOGICAL_AND_PRECEDENCE);

  /// A value used to indicate that the token type is a logical-or operator.
  static const TokenClass LOGICAL_OR_OPERATOR =
      TokenClass('LOGICAL_OR_OPERATOR', LOGICAL_OR_PRECEDENCE);

  /// A value used to indicate that the token type is a multiplicative operator.
  static const TokenClass MULTIPLICATIVE_OPERATOR =
      TokenClass('MULTIPLICATIVE_OPERATOR', MULTIPLICATIVE_PRECEDENCE);

  /// A value used to indicate that the token type is a relational operator.
  static const TokenClass RELATIONAL_OPERATOR =
      TokenClass('RELATIONAL_OPERATOR', RELATIONAL_PRECEDENCE);

  /// A value used to indicate that the token type is a shift operator.
  static const TokenClass SHIFT_OPERATOR =
      TokenClass('SHIFT_OPERATOR', SHIFT_PRECEDENCE);

  /// A value used to indicate that the token type is a unary operator.
  static const TokenClass UNARY_POSTFIX_OPERATOR =
      TokenClass('UNARY_POSTFIX_OPERATOR', POSTFIX_PRECEDENCE);

  /// A value used to indicate that the token type is a unary operator.
  static const TokenClass UNARY_PREFIX_OPERATOR =
      TokenClass('UNARY_PREFIX_OPERATOR', PREFIX_PRECEDENCE);

  /// The name of the token class.
  final String name;

  /// The precedence of tokens of this class, or `0` if the such tokens do not
  /// represent an operator.
  final int precedence;

  /// Initialize a newly created class of tokens to have the given [name] and
  /// [precedence].
  const TokenClass(this.name, [this.precedence = NO_PRECEDENCE]);

  @override
  String toString() => name;
}

/// The types of tokens that can be returned by the scanner.
///
/// Clients may not extend, implement or mix-in this class.
class TokenType {
  /// The type of the token that marks the start or end of the input.
  static const TokenType EOF = TokenType('', 'EOF', NO_PRECEDENCE, EOF_TOKEN);

  static const TokenType DOUBLE = TokenType(
      'double', 'DOUBLE', NO_PRECEDENCE, DOUBLE_TOKEN,
      stringValue: null);

  static const TokenType HEXADECIMAL = TokenType(
      'hexadecimal', 'HEXADECIMAL', NO_PRECEDENCE, HEXADECIMAL_TOKEN,
      stringValue: null);

  static const TokenType IDENTIFIER = TokenType(
      'identifier', 'IDENTIFIER', NO_PRECEDENCE, IDENTIFIER_TOKEN,
      stringValue: null);

  static const TokenType INT =
      TokenType('int', 'INT', NO_PRECEDENCE, INT_TOKEN, stringValue: null);

  static const TokenType MULTI_LINE_COMMENT = TokenType(
      'comment', 'MULTI_LINE_COMMENT', NO_PRECEDENCE, COMMENT_TOKEN,
      stringValue: null);

  static const TokenType SCRIPT_TAG =
      TokenType('script', 'SCRIPT_TAG', NO_PRECEDENCE, SCRIPT_TOKEN);

  static const TokenType SINGLE_LINE_COMMENT = TokenType(
      'comment', 'SINGLE_LINE_COMMENT', NO_PRECEDENCE, COMMENT_TOKEN,
      stringValue: null);

  static const TokenType STRING = TokenType(
      'string', 'STRING', NO_PRECEDENCE, STRING_TOKEN,
      stringValue: null);

  static const TokenType AMPERSAND = TokenType(
      '&', 'AMPERSAND', BITWISE_AND_PRECEDENCE, AMPERSAND_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  static const TokenType AMPERSAND_AMPERSAND = TokenType('&&',
      'AMPERSAND_AMPERSAND', LOGICAL_AND_PRECEDENCE, AMPERSAND_AMPERSAND_TOKEN,
      isOperator: true, isBinaryOperator: true);

  // This is not yet part of the language and not supported by fasta
  static const TokenType AMPERSAND_AMPERSAND_EQ = TokenType(
      '&&=',
      'AMPERSAND_AMPERSAND_EQ',
      ASSIGNMENT_PRECEDENCE,
      AMPERSAND_AMPERSAND_EQ_TOKEN,
      binaryOperatorOfCompoundAssignment: TokenType.AMPERSAND_AMPERSAND,
      isOperator: true);

  static const TokenType AMPERSAND_EQ = TokenType(
      '&=', 'AMPERSAND_EQ', ASSIGNMENT_PRECEDENCE, AMPERSAND_EQ_TOKEN,
      binaryOperatorOfCompoundAssignment: TokenType.AMPERSAND,
      isOperator: true);

  static const TokenType AT = TokenType('@', 'AT', NO_PRECEDENCE, AT_TOKEN);

  static const TokenType BANG =
      TokenType('!', 'BANG', PREFIX_PRECEDENCE, BANG_TOKEN, isOperator: true);

  static const TokenType BANG_EQ = TokenType(
      '!=', 'BANG_EQ', EQUALITY_PRECEDENCE, BANG_EQ_TOKEN,
      isOperator: true);

  static const TokenType BANG_EQ_EQ =
      TokenType('!==', 'BANG_EQ_EQ', EQUALITY_PRECEDENCE, BANG_EQ_EQ_TOKEN);

  static const TokenType BAR = TokenType(
      '|', 'BAR', BITWISE_OR_PRECEDENCE, BAR_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  static const TokenType BAR_BAR = TokenType(
      '||', 'BAR_BAR', LOGICAL_OR_PRECEDENCE, BAR_BAR_TOKEN,
      isOperator: true, isBinaryOperator: true);

  // This is not yet part of the language and not supported by fasta
  static const TokenType BAR_BAR_EQ = TokenType(
      '||=', 'BAR_BAR_EQ', ASSIGNMENT_PRECEDENCE, BAR_BAR_EQ_TOKEN,
      binaryOperatorOfCompoundAssignment: TokenType.BAR_BAR, isOperator: true);

  static const TokenType BAR_EQ = TokenType(
      '|=', 'BAR_EQ', ASSIGNMENT_PRECEDENCE, BAR_EQ_TOKEN,
      binaryOperatorOfCompoundAssignment: TokenType.BAR, isOperator: true);

  static const TokenType COLON =
      TokenType(':', 'COLON', NO_PRECEDENCE, COLON_TOKEN);

  static const TokenType COMMA =
      TokenType(',', 'COMMA', NO_PRECEDENCE, COMMA_TOKEN);

  static const TokenType CARET = TokenType(
      '^', 'CARET', BITWISE_XOR_PRECEDENCE, CARET_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  static const TokenType CARET_EQ = TokenType(
      '^=', 'CARET_EQ', ASSIGNMENT_PRECEDENCE, CARET_EQ_TOKEN,
      binaryOperatorOfCompoundAssignment: TokenType.CARET, isOperator: true);

  static const TokenType CLOSE_CURLY_BRACKET = TokenType(
      '}', 'CLOSE_CURLY_BRACKET', NO_PRECEDENCE, CLOSE_CURLY_BRACKET_TOKEN);

  static const TokenType CLOSE_PAREN =
      TokenType(')', 'CLOSE_PAREN', NO_PRECEDENCE, CLOSE_PAREN_TOKEN);

  static const TokenType CLOSE_SQUARE_BRACKET = TokenType(
      ']', 'CLOSE_SQUARE_BRACKET', NO_PRECEDENCE, CLOSE_SQUARE_BRACKET_TOKEN);

  static const TokenType EQ =
      TokenType('=', 'EQ', ASSIGNMENT_PRECEDENCE, EQ_TOKEN, isOperator: true);

  static const TokenType EQ_EQ = TokenType(
      '==', 'EQ_EQ', EQUALITY_PRECEDENCE, EQ_EQ_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  /// The `===` operator is not supported in the Dart language
  /// but is parsed as such by the scanner to support better recovery
  /// when a JavaScript code snippet is pasted into a Dart file.
  static const TokenType EQ_EQ_EQ =
      TokenType('===', 'EQ_EQ_EQ', EQUALITY_PRECEDENCE, EQ_EQ_EQ_TOKEN);

  static const TokenType FUNCTION =
      TokenType('=>', 'FUNCTION', NO_PRECEDENCE, FUNCTION_TOKEN);

  static const TokenType GT = TokenType(
      '>', 'GT', RELATIONAL_PRECEDENCE, GT_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  static const TokenType GT_EQ = TokenType(
      '>=', 'GT_EQ', RELATIONAL_PRECEDENCE, GT_EQ_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  static const TokenType GT_GT = TokenType(
      '>>', 'GT_GT', SHIFT_PRECEDENCE, GT_GT_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  static const TokenType GT_GT_EQ = TokenType(
      '>>=', 'GT_GT_EQ', ASSIGNMENT_PRECEDENCE, GT_GT_EQ_TOKEN,
      binaryOperatorOfCompoundAssignment: TokenType.GT_GT, isOperator: true);

  static const TokenType GT_GT_GT = TokenType(
      '>>>', 'GT_GT_GT', SHIFT_PRECEDENCE, GT_GT_GT_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  static const TokenType GT_GT_GT_EQ = TokenType(
      '>>>=', 'GT_GT_GT_EQ', ASSIGNMENT_PRECEDENCE, GT_GT_GT_EQ_TOKEN,
      binaryOperatorOfCompoundAssignment: TokenType.GT_GT_GT, isOperator: true);

  static const TokenType HASH =
      TokenType('#', 'HASH', NO_PRECEDENCE, HASH_TOKEN);

  static const TokenType INDEX = TokenType(
      '[]', 'INDEX', SELECTOR_PRECEDENCE, INDEX_TOKEN,
      isOperator: true, isUserDefinableOperator: true);

  static const TokenType INDEX_EQ = TokenType(
      '[]=', 'INDEX_EQ', NO_PRECEDENCE, INDEX_EQ_TOKEN,
      isOperator: true, isUserDefinableOperator: true);

  static const TokenType LT = TokenType(
      '<', 'LT', RELATIONAL_PRECEDENCE, LT_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  static const TokenType LT_EQ = TokenType(
      '<=', 'LT_EQ', RELATIONAL_PRECEDENCE, LT_EQ_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  static const TokenType LT_LT = TokenType(
      '<<', 'LT_LT', SHIFT_PRECEDENCE, LT_LT_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  static const TokenType LT_LT_EQ = TokenType(
      '<<=', 'LT_LT_EQ', ASSIGNMENT_PRECEDENCE, LT_LT_EQ_TOKEN,
      binaryOperatorOfCompoundAssignment: TokenType.LT_LT, isOperator: true);

  static const TokenType MINUS = TokenType(
      '-', 'MINUS', ADDITIVE_PRECEDENCE, MINUS_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  static const TokenType MINUS_EQ = TokenType(
      '-=', 'MINUS_EQ', ASSIGNMENT_PRECEDENCE, MINUS_EQ_TOKEN,
      binaryOperatorOfCompoundAssignment: TokenType.MINUS, isOperator: true);

  static const TokenType MINUS_MINUS = TokenType(
      '--', 'MINUS_MINUS', POSTFIX_PRECEDENCE, MINUS_MINUS_TOKEN,
      isOperator: true);

  static const TokenType OPEN_CURLY_BRACKET = TokenType(
      '{', 'OPEN_CURLY_BRACKET', NO_PRECEDENCE, OPEN_CURLY_BRACKET_TOKEN);

  static const TokenType OPEN_PAREN =
      TokenType('(', 'OPEN_PAREN', SELECTOR_PRECEDENCE, OPEN_PAREN_TOKEN);

  static const TokenType OPEN_SQUARE_BRACKET = TokenType('[',
      'OPEN_SQUARE_BRACKET', SELECTOR_PRECEDENCE, OPEN_SQUARE_BRACKET_TOKEN);

  static const TokenType PERCENT = TokenType(
      '%', 'PERCENT', MULTIPLICATIVE_PRECEDENCE, PERCENT_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  static const TokenType PERCENT_EQ = TokenType(
      '%=', 'PERCENT_EQ', ASSIGNMENT_PRECEDENCE, PERCENT_EQ_TOKEN,
      binaryOperatorOfCompoundAssignment: TokenType.PERCENT, isOperator: true);

  static const TokenType PERIOD =
      TokenType('.', 'PERIOD', SELECTOR_PRECEDENCE, PERIOD_TOKEN);

  static const TokenType PERIOD_PERIOD = TokenType(
      '..', 'PERIOD_PERIOD', CASCADE_PRECEDENCE, PERIOD_PERIOD_TOKEN,
      isOperator: true);

  static const TokenType PLUS = TokenType(
      '+', 'PLUS', ADDITIVE_PRECEDENCE, PLUS_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  static const TokenType PLUS_EQ = TokenType(
      '+=', 'PLUS_EQ', ASSIGNMENT_PRECEDENCE, PLUS_EQ_TOKEN,
      binaryOperatorOfCompoundAssignment: TokenType.PLUS, isOperator: true);

  static const TokenType PLUS_PLUS = TokenType(
      '++', 'PLUS_PLUS', POSTFIX_PRECEDENCE, PLUS_PLUS_TOKEN,
      isOperator: true);

  static const TokenType QUESTION = TokenType(
      '?', 'QUESTION', CONDITIONAL_PRECEDENCE, QUESTION_TOKEN,
      isOperator: true);

  static const TokenType QUESTION_PERIOD = TokenType(
      '?.', 'QUESTION_PERIOD', SELECTOR_PRECEDENCE, QUESTION_PERIOD_TOKEN,
      isOperator: true);

  static const TokenType QUESTION_QUESTION = TokenType(
      '??', 'QUESTION_QUESTION', IF_NULL_PRECEDENCE, QUESTION_QUESTION_TOKEN,
      isOperator: true, isBinaryOperator: true);

  static const TokenType QUESTION_QUESTION_EQ = TokenType('??=',
      'QUESTION_QUESTION_EQ', ASSIGNMENT_PRECEDENCE, QUESTION_QUESTION_EQ_TOKEN,
      binaryOperatorOfCompoundAssignment: TokenType.QUESTION_QUESTION,
      isOperator: true);

  static const TokenType SEMICOLON =
      TokenType(';', 'SEMICOLON', NO_PRECEDENCE, SEMICOLON_TOKEN);

  static const TokenType SLASH = TokenType(
      '/', 'SLASH', MULTIPLICATIVE_PRECEDENCE, SLASH_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  static const TokenType SLASH_EQ = TokenType(
      '/=', 'SLASH_EQ', ASSIGNMENT_PRECEDENCE, SLASH_EQ_TOKEN,
      binaryOperatorOfCompoundAssignment: TokenType.SLASH, isOperator: true);

  static const TokenType STAR = TokenType(
      '*', 'STAR', MULTIPLICATIVE_PRECEDENCE, STAR_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  static const TokenType STAR_EQ = TokenType(
      '*=', 'STAR_EQ', ASSIGNMENT_PRECEDENCE, STAR_EQ_TOKEN,
      binaryOperatorOfCompoundAssignment: TokenType.STAR, isOperator: true);

  static const TokenType STRING_INTERPOLATION_EXPRESSION = TokenType(
      '\${',
      'STRING_INTERPOLATION_EXPRESSION',
      NO_PRECEDENCE,
      STRING_INTERPOLATION_TOKEN);

  static const TokenType STRING_INTERPOLATION_IDENTIFIER = TokenType(
      '\$',
      'STRING_INTERPOLATION_IDENTIFIER',
      NO_PRECEDENCE,
      STRING_INTERPOLATION_IDENTIFIER_TOKEN);

  static const TokenType TILDE = TokenType(
      '~', 'TILDE', PREFIX_PRECEDENCE, TILDE_TOKEN,
      isOperator: true, isUserDefinableOperator: true);

  static const TokenType TILDE_SLASH = TokenType(
      '~/', 'TILDE_SLASH', MULTIPLICATIVE_PRECEDENCE, TILDE_SLASH_TOKEN,
      isOperator: true, isBinaryOperator: true, isUserDefinableOperator: true);

  static const TokenType TILDE_SLASH_EQ = TokenType(
      '~/=', 'TILDE_SLASH_EQ', ASSIGNMENT_PRECEDENCE, TILDE_SLASH_EQ_TOKEN,
      binaryOperatorOfCompoundAssignment: TokenType.TILDE_SLASH,
      isOperator: true);

  static const TokenType BACKPING =
      TokenType('`', 'BACKPING', NO_PRECEDENCE, BACKPING_TOKEN);

  static const TokenType BACKSLASH =
      TokenType('\\', 'BACKSLASH', NO_PRECEDENCE, BACKSLASH_TOKEN);

  static const TokenType PERIOD_PERIOD_PERIOD = TokenType(
      '...', 'PERIOD_PERIOD_PERIOD', NO_PRECEDENCE, PERIOD_PERIOD_PERIOD_TOKEN);

  static const TokenType PERIOD_PERIOD_PERIOD_QUESTION = TokenType(
      '...?',
      'PERIOD_PERIOD_PERIOD_QUESTION',
      NO_PRECEDENCE,
      PERIOD_PERIOD_PERIOD_QUESTION_TOKEN);

  static const TokenType QUESTION_PERIOD_PERIOD = TokenType(
      '?..',
      'QUESTION_PERIOD_PERIOD',
      CASCADE_PRECEDENCE,
      QUESTION_PERIOD_PERIOD_TOKEN);

  // static const TokenType AS = Keyword.AS;

  // static const TokenType IS = Keyword.IS;

  /// Token type used by error tokens.
  static const TokenType BAD_INPUT = TokenType(
      'malformed input', 'BAD_INPUT', NO_PRECEDENCE, BAD_INPUT_TOKEN,
      stringValue: null);

  /// Token type used by synthetic tokens that are created during parser
  /// recovery (non-analyzer use case).
  static const TokenType RECOVERY = TokenType(
      'recovery', 'RECOVERY', NO_PRECEDENCE, RECOVERY_TOKEN,
      stringValue: null);

  // TODO(danrubel): "all" is misleading
  // because this list does not include all TokenType instances.
  static const List<TokenType> all = <TokenType>[
    TokenType.EOF,
    TokenType.DOUBLE,
    TokenType.HEXADECIMAL,
    TokenType.IDENTIFIER,
    TokenType.INT,
    TokenType.MULTI_LINE_COMMENT,
    TokenType.SCRIPT_TAG,
    TokenType.SINGLE_LINE_COMMENT,
    TokenType.STRING,
    TokenType.AMPERSAND,
    TokenType.AMPERSAND_AMPERSAND,
    TokenType.AMPERSAND_EQ,
    TokenType.AT,
    TokenType.BANG,
    TokenType.BANG_EQ,
    TokenType.BAR,
    TokenType.BAR_BAR,
    TokenType.BAR_EQ,
    TokenType.COLON,
    TokenType.COMMA,
    TokenType.CARET,
    TokenType.CARET_EQ,
    TokenType.CLOSE_CURLY_BRACKET,
    TokenType.CLOSE_PAREN,
    TokenType.CLOSE_SQUARE_BRACKET,
    TokenType.EQ,
    TokenType.EQ_EQ,
    TokenType.FUNCTION,
    TokenType.GT,
    TokenType.GT_EQ,
    TokenType.GT_GT,
    TokenType.GT_GT_EQ,
    TokenType.HASH,
    TokenType.INDEX,
    TokenType.INDEX_EQ,
    TokenType.LT,
    TokenType.LT_EQ,
    TokenType.LT_LT,
    TokenType.LT_LT_EQ,
    TokenType.MINUS,
    TokenType.MINUS_EQ,
    TokenType.MINUS_MINUS,
    TokenType.OPEN_CURLY_BRACKET,
    TokenType.OPEN_PAREN,
    TokenType.OPEN_SQUARE_BRACKET,
    TokenType.PERCENT,
    TokenType.PERCENT_EQ,
    TokenType.PERIOD,
    TokenType.PERIOD_PERIOD,
    TokenType.PLUS,
    TokenType.PLUS_EQ,
    TokenType.PLUS_PLUS,
    TokenType.QUESTION,
    TokenType.QUESTION_PERIOD,
    TokenType.QUESTION_QUESTION,
    TokenType.QUESTION_QUESTION_EQ,
    TokenType.SEMICOLON,
    TokenType.SLASH,
    TokenType.SLASH_EQ,
    TokenType.STAR,
    TokenType.STAR_EQ,
    TokenType.STRING_INTERPOLATION_EXPRESSION,
    TokenType.STRING_INTERPOLATION_IDENTIFIER,
    TokenType.TILDE,
    TokenType.TILDE_SLASH,
    TokenType.TILDE_SLASH_EQ,
    TokenType.BACKPING,
    TokenType.BACKSLASH,
    TokenType.PERIOD_PERIOD_PERIOD,
    TokenType.PERIOD_PERIOD_PERIOD_QUESTION,

    // TODO(danrubel): Should these be added to the "all" list?
    //TokenType.IS,
    //TokenType.AS,

    // These are not yet part of the language and not supported by fasta
    //TokenType.AMPERSAND_AMPERSAND_EQ,
    //TokenType.BAR_BAR_EQ,

    // Supported by fasta but not part of the language
    //TokenType.BANG_EQ_EQ,
    //TokenType.EQ_EQ_EQ,

    // Used by synthetic tokens generated during recovery
    //TokenType.BAD_INPUT,
    //TokenType.RECOVERY,
  ];

  /// The binary operator that is invoked by this compound assignment operator,
  /// or `null` otherwise.
  final TokenType? binaryOperatorOfCompoundAssignment;

  final int kind;

  /// `true` if this token type represents a modifier
  /// such as `abstract` or `const`.
  final bool isModifier;

  /// `true` if this token type represents an operator.
  final bool isOperator;

  /// `true` if this token type represents a binary operator.
  final bool isBinaryOperator;

  /// `true` if this token type represents a keyword starting a top level
  /// declaration such as `class`, `enum`, `import`, etc.
  final bool isTopLevelKeyword;

  /// `true` if this token type represents an operator
  /// that can be defined by users.
  final bool isUserDefinableOperator;

  /// The lexeme that defines this type of token,
  /// or `null` if there is more than one possible lexeme for this type of token.
  final String lexeme;

  /// The name of the token type.
  final String name;

  /// The precedence of this type of token,
  /// or `0` if the token does not represent an operator.
  final int precedence;

  /// See [Token.stringValue] for an explanation.
  final String? stringValue;

  const TokenType(this.lexeme, this.name, this.precedence, this.kind,
      {this.binaryOperatorOfCompoundAssignment,
      this.isBinaryOperator: false,
      this.isModifier: false,
      this.isOperator: false,
      this.isTopLevelKeyword: false,
      this.isUserDefinableOperator: false,
      String? stringValue: 'unspecified'})
      : stringValue = stringValue == 'unspecified' ? lexeme : stringValue;

  /// Return `true` if this type of token represents an additive operator.
  bool get isAdditiveOperator => precedence == ADDITIVE_PRECEDENCE;

  /// Return `true` if this type of token represents an assignment operator.
  bool get isAssignmentOperator => precedence == ASSIGNMENT_PRECEDENCE;

  /// Return `true` if this type of token represents an associative operator. An
  /// associative operator is an operator for which the following equality is
  /// true: `(a * b) * c == a * (b * c)`. In other words, if the result of
  /// applying the operator to multiple operands does not depend on the order in
  /// which those applications occur.
  ///
  /// Note: This method considers the logical-and and logical-or operators to be
  /// associative, even though the order in which the application of those
  /// operators can have an effect because evaluation of the right-hand operand
  /// is conditional.
  bool get isAssociativeOperator =>
      this == TokenType.AMPERSAND ||
      this == TokenType.AMPERSAND_AMPERSAND ||
      this == TokenType.BAR ||
      this == TokenType.BAR_BAR ||
      this == TokenType.CARET ||
      this == TokenType.PLUS ||
      this == TokenType.STAR;

  /// A flag indicating whether the keyword is a "built-in" identifier.
  bool get isBuiltIn => false;

  /// A flag indicating whether the keyword is a "reserved word".
  bool get isReservedWord => false;

  /// Return `true` if this type of token represents an equality operator.
  bool get isEqualityOperator =>
      this == TokenType.BANG_EQ || this == TokenType.EQ_EQ;

  /// Return `true` if this type of token represents an increment operator.
  bool get isIncrementOperator =>
      this == TokenType.PLUS_PLUS || this == TokenType.MINUS_MINUS;

  /// Return `true` if this type of token is a keyword.
  bool get isKeyword => kind == KEYWORD_TOKEN;

  /// A flag indicating whether the keyword can be used as an identifier
  /// in some situations.
  bool get isPseudo => false;

  /// Return `true` if this type of token represents a multiplicative operator.
  bool get isMultiplicativeOperator => precedence == MULTIPLICATIVE_PRECEDENCE;

  /// Return `true` if this type of token represents a relational operator.
  bool get isRelationalOperator =>
      this == TokenType.LT ||
      this == TokenType.LT_EQ ||
      this == TokenType.GT ||
      this == TokenType.GT_EQ;

  /// Return `true` if this type of token represents a shift operator.
  bool get isShiftOperator => precedence == SHIFT_PRECEDENCE;

  /// Return `true` if this type of token represents a unary postfix operator.
  bool get isUnaryPostfixOperator => precedence == POSTFIX_PRECEDENCE;

  /// Return `true` if this type of token represents a unary prefix operator.
  bool get isUnaryPrefixOperator =>
      precedence == PREFIX_PRECEDENCE ||
      this == TokenType.MINUS ||
      this == TokenType.PLUS_PLUS ||
      this == TokenType.MINUS_MINUS;

  /// Return `true` if this type of token represents a selector operator
  /// (starting token of a selector).
  bool get isSelectorOperator => precedence == SELECTOR_PRECEDENCE;

  @override
  String toString() => name;
}

/// A synthetic token.
class SyntheticToken extends SimpleToken {
  SyntheticToken({required TokenType type, required int offset})
      : super(type: type, offset: offset);

  @override
  Token? beforeSynthetic;

  @override
  bool get isSynthetic => true;

  @override
  int get length => 0;

  @override
  Token copy() => SyntheticToken(type: type, offset: offset);
}

/// A synthetic token.
class SyntheticBeginToken extends BeginToken {
  SyntheticBeginToken({required TokenType type, required int offset})
      : super(type: type, offset: offset);

  @override
  bool get isSynthetic => true;

  @override
  int get length => 0;

  @override
  Token copy() => SyntheticBeginToken(type: type, offset: offset);
}

/// A token used to replace another token in the stream, while still keeping the
/// old token around (in [replacedToken]). Automatically sets the offset and
/// precedingComments from the data available on [replacedToken].
class ReplacementToken extends SyntheticToken {
  /// The token that this token replaces. This will normally be the token
  /// representing what the user actually wrote.
  final Token replacedToken;

  ReplacementToken({required TokenType type, required this.replacedToken})
      : super(type: type, offset: replacedToken.offset) {
    precedingComments = replacedToken.precedingComments;
  }

  @override
  Token? beforeSynthetic;

  @override
  bool get isSynthetic => true;

  @override
  int get length => 0;

  @override
  Token copy() => ReplacementToken(type: type, replacedToken: replacedToken);
}
