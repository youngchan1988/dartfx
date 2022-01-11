import 'dart:convert';
import 'dart:typed_data';

import 'package:dartfx/src/lexer/scanner/characters.dart';

import 'scanner/utf8_bytes_scanner.dart';

import 'lexer.dart';
import 'tokens/token.dart';

///
///Author: YoungChan
///Date: 2021-12-30 10:58:22
///LastEditors: YoungChan
///LastEditTime: 2021-12-30 12:04:07
///Description: Lexer for expression string
///Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

class ExpressionLexer extends Lexer {
  ExpressionLexer({required this.expression})
      : super(
            scanner: Utf8BytesScanner(
                bytes: List.from(utf8.encode(expression))..add($EOF)));

  String expression;

  Token scan() {
    return scanner.tokenize();
  }
}
