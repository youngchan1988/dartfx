// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details (https://github.com/dart-lang/sdk/blob/main/AUTHORS). All rights
//reserved. Use of this source code is governed by a BSD-style license that can
// be found in the LICENSE file.

// Modified by the dartfx project authors.
// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'token.dart';
import 'token_constants.dart';

enum KeywordStyle {
  reserved,
  builtIn,
  pseudo,
}

/// The keywords in the Dart programming language.
///
/// Clients may not extend, implement or mix-in this class.
class Keyword extends TokenType {
  static const Keyword ABSTRACT =
      Keyword("abstract", "ABSTRACT", KeywordStyle.builtIn, isModifier: true);

  static const Keyword AS = Keyword("as", "AS", KeywordStyle.builtIn,
      precedence: RELATIONAL_PRECEDENCE);

  static const Keyword ASSERT =
      Keyword("assert", "ASSERT", KeywordStyle.reserved);

  static const Keyword ASYNC = Keyword("async", "ASYNC", KeywordStyle.pseudo);

  static const Keyword AWAIT = Keyword("await", "AWAIT", KeywordStyle.pseudo);

  static const Keyword BREAK = Keyword("break", "BREAK", KeywordStyle.reserved);

  static const Keyword CASE = Keyword("case", "CASE", KeywordStyle.reserved);

  static const Keyword CATCH = Keyword("catch", "CATCH", KeywordStyle.reserved);

  static const Keyword CLASS =
      Keyword("class", "CLASS", KeywordStyle.reserved, isTopLevelKeyword: true);

  static const Keyword CONST =
      Keyword("const", "CONST", KeywordStyle.reserved, isModifier: true);

  static const Keyword CONTINUE =
      Keyword("continue", "CONTINUE", KeywordStyle.reserved);

  static const Keyword COVARIANT =
      Keyword("covariant", "COVARIANT", KeywordStyle.builtIn, isModifier: true);

  static const Keyword DEFAULT =
      Keyword("default", "DEFAULT", KeywordStyle.reserved);

  static const Keyword DEFERRED =
      Keyword("deferred", "DEFERRED", KeywordStyle.builtIn);

  static const Keyword DO = Keyword("do", "DO", KeywordStyle.reserved);

  static const Keyword DYNAMIC =
      Keyword("dynamic", "DYNAMIC", KeywordStyle.builtIn);

  static const Keyword ELSE = Keyword("else", "ELSE", KeywordStyle.reserved);

  static const Keyword ENUM =
      Keyword("enum", "ENUM", KeywordStyle.reserved, isTopLevelKeyword: true);

  static const Keyword EXPORT = Keyword(
      "export", "EXPORT", KeywordStyle.builtIn,
      isTopLevelKeyword: true);

  static const Keyword EXTENDS =
      Keyword("extends", "EXTENDS", KeywordStyle.reserved);

  static const Keyword EXTENSION = Keyword(
      "extension", "EXTENSION", KeywordStyle.builtIn,
      isTopLevelKeyword: true);

  static const Keyword EXTERNAL =
      Keyword("external", "EXTERNAL", KeywordStyle.builtIn, isModifier: true);

  static const Keyword FACTORY =
      Keyword("factory", "FACTORY", KeywordStyle.builtIn);

  static const Keyword FALSE = Keyword("false", "FALSE", KeywordStyle.reserved);

  static const Keyword FINAL =
      Keyword("final", "FINAL", KeywordStyle.reserved, isModifier: true);

  static const Keyword FINALLY =
      Keyword("finally", "FINALLY", KeywordStyle.reserved);

  static const Keyword FOR = Keyword("for", "FOR", KeywordStyle.reserved);

  static const Keyword FUNCTION =
      Keyword("Function", "FUNCTION", KeywordStyle.pseudo);

  static const Keyword GET = Keyword("get", "GET", KeywordStyle.builtIn);

  static const Keyword HIDE = Keyword("hide", "HIDE", KeywordStyle.pseudo);

  static const Keyword IF = Keyword("if", "IF", KeywordStyle.reserved);

  static const Keyword IMPLEMENTS =
      Keyword("implements", "IMPLEMENTS", KeywordStyle.builtIn);

  static const Keyword IMPORT = Keyword(
      "import", "IMPORT", KeywordStyle.builtIn,
      isTopLevelKeyword: true);

  static const Keyword IN = Keyword("in", "IN", KeywordStyle.reserved);

  static const Keyword INOUT = Keyword("inout", "INOUT", KeywordStyle.pseudo);

  static const Keyword INTERFACE =
      Keyword("interface", "INTERFACE", KeywordStyle.builtIn);

  static const Keyword IS = Keyword("is", "IS", KeywordStyle.reserved,
      precedence: RELATIONAL_PRECEDENCE);

  static const Keyword LATE =
      Keyword("late", "LATE", KeywordStyle.builtIn, isModifier: true);

  static const Keyword LIBRARY = Keyword(
      "library", "LIBRARY", KeywordStyle.builtIn,
      isTopLevelKeyword: true);

  static const Keyword MIXIN =
      Keyword("mixin", "MIXIN", KeywordStyle.builtIn, isTopLevelKeyword: true);

  static const Keyword NATIVE =
      Keyword("native", "NATIVE", KeywordStyle.pseudo);

  static const Keyword NEW = Keyword("new", "NEW", KeywordStyle.reserved);

  static const Keyword NULL = Keyword("null", "NULL", KeywordStyle.reserved);

  static const Keyword OF = Keyword("of", "OF", KeywordStyle.pseudo);

  static const Keyword ON = Keyword("on", "ON", KeywordStyle.pseudo);

  static const Keyword OPERATOR =
      Keyword("operator", "OPERATOR", KeywordStyle.builtIn);

  static const Keyword OUT = Keyword("out", "OUT", KeywordStyle.pseudo);

  static const Keyword PART =
      Keyword("part", "PART", KeywordStyle.builtIn, isTopLevelKeyword: true);

  static const Keyword PATCH = Keyword("patch", "PATCH", KeywordStyle.pseudo);

  static const Keyword REQUIRED =
      Keyword("required", "REQUIRED", KeywordStyle.builtIn, isModifier: true);

  static const Keyword RETHROW =
      Keyword("rethrow", "RETHROW", KeywordStyle.reserved);

  static const Keyword RETURN =
      Keyword("return", "RETURN", KeywordStyle.reserved);

  static const Keyword SET = Keyword("set", "SET", KeywordStyle.builtIn);

  static const Keyword SHOW = Keyword("show", "SHOW", KeywordStyle.pseudo);

  static const Keyword SOURCE =
      Keyword("source", "SOURCE", KeywordStyle.pseudo);

  static const Keyword STATIC =
      Keyword("static", "STATIC", KeywordStyle.builtIn, isModifier: true);

  static const Keyword SUPER = Keyword("super", "SUPER", KeywordStyle.reserved);

  static const Keyword SWITCH =
      Keyword("switch", "SWITCH", KeywordStyle.reserved);

  static const Keyword SYNC = Keyword("sync", "SYNC", KeywordStyle.pseudo);

  static const Keyword THIS = Keyword("this", "THIS", KeywordStyle.reserved);

  static const Keyword THROW = Keyword("throw", "THROW", KeywordStyle.reserved);

  static const Keyword TRUE = Keyword("true", "TRUE", KeywordStyle.reserved);

  static const Keyword TRY = Keyword("try", "TRY", KeywordStyle.reserved);

  static const Keyword TYPEDEF = Keyword(
      "typedef", "TYPEDEF", KeywordStyle.builtIn,
      isTopLevelKeyword: true);

  static const Keyword VAR =
      Keyword("var", "VAR", KeywordStyle.reserved, isModifier: true);

  static const Keyword VOID = Keyword("void", "VOID", KeywordStyle.reserved);

  static const Keyword WHILE = Keyword("while", "WHILE", KeywordStyle.reserved);

  static const Keyword WITH = Keyword("with", "WITH", KeywordStyle.reserved);

  static const Keyword YIELD = Keyword("yield", "YIELD", KeywordStyle.pseudo);

  static const List<Keyword> values = <Keyword>[
    ABSTRACT,
    AS,
    ASSERT,
    ASYNC,
    AWAIT,
    BREAK,
    CASE,
    CATCH,
    CLASS,
    CONST,
    CONTINUE,
    COVARIANT,
    DEFAULT,
    DEFERRED,
    DO,
    DYNAMIC,
    ELSE,
    ENUM,
    EXPORT,
    EXTENDS,
    EXTENSION,
    EXTERNAL,
    FACTORY,
    FALSE,
    FINAL,
    FINALLY,
    FOR,
    FUNCTION,
    GET,
    HIDE,
    IF,
    IMPLEMENTS,
    IMPORT,
    IN,
    INOUT,
    INTERFACE,
    IS,
    LATE,
    LIBRARY,
    MIXIN,
    NATIVE,
    NEW,
    NULL,
    OF,
    ON,
    OPERATOR,
    OUT,
    PART,
    PATCH,
    REQUIRED,
    RETHROW,
    RETURN,
    SET,
    SHOW,
    SOURCE,
    STATIC,
    SUPER,
    SWITCH,
    SYNC,
    THIS,
    THROW,
    TRUE,
    TRY,
    TYPEDEF,
    VAR,
    VOID,
    WHILE,
    WITH,
    YIELD,
  ];

  /// A table mapping the lexemes of keywords to the corresponding keyword.
  static final Map<String, Keyword> keywords = _createKeywordMap();

  final KeywordStyle keywordStyle;

  /// Initialize a newly created keyword.
  const Keyword(String lexeme, String name, this.keywordStyle,
      {bool isModifier: false,
      bool isTopLevelKeyword: false,
      int precedence: NO_PRECEDENCE})
      : super(lexeme, name, precedence, KEYWORD_TOKEN,
            isModifier: isModifier, isTopLevelKeyword: isTopLevelKeyword);

  @override
  bool get isBuiltIn => keywordStyle == KeywordStyle.builtIn;

  @override
  bool get isPseudo => keywordStyle == KeywordStyle.pseudo;

  bool get isBuiltInOrPseudo => isBuiltIn || isPseudo;

  @override
  bool get isReservedWord => keywordStyle == KeywordStyle.reserved;

  /// The name of the keyword type.
  String get name => lexeme.toUpperCase();

  @override
  String toString() => name;

  /// Create a table mapping the lexemes of keywords to the corresponding keyword
  /// and return the table that was created.
  static Map<String, Keyword> _createKeywordMap() {
    var result = LinkedHashMap<String, Keyword>();
    for (Keyword keyword in values) {
      result[keyword.lexeme] = keyword;
    }
    return result;
  }
}

/// A token representing a keyword in the language.
class KeywordToken extends SimpleToken {
  /// Initialize a newly created token to represent the given [keyword] at the
  /// given [offset].
  KeywordToken({required this.keyword, int offset = 0})
      : super(type: keyword, offset: offset);

  @override
  final Keyword keyword;

  @override
  bool get isIdentifier => keyword.isPseudo || keyword.isBuiltIn;

  @override
  bool get isKeyword => true;

  @override
  bool get isKeywordOrIdentifier => true;

  @override
  Object value() => keyword;
}

/**
 * A synthetic keyword token.
 */
class SyntheticKeywordToken extends KeywordToken {
  /**
   * Initialize a newly created token to represent the given [keyword] at the
   * given [offset].
   */
  SyntheticKeywordToken({required Keyword keyword, required int offset})
      : super(keyword: keyword, offset: offset);

  @override
  int get length => 0;

  @override
  Token copy() => SyntheticKeywordToken(keyword: keyword, offset: offset);
}
