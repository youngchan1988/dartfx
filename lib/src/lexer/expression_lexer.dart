// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'package:dartfx/src/lexer/scanner/characters.dart';
import 'scanner/utf8_bytes_scanner.dart';
import 'lexer.dart';
import 'tokens/token.dart';

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
