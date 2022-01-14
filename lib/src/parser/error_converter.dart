// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Modified by the dartfx project authors.
// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/lexer/tokens/error_token.dart';
import 'package:dartfx/src/lexer/tokens/token.dart';
import 'package:dartfx/src/lexer/tokens/token_constants.dart';

import '../messages/codes.dart'
    show Code, Message, codeUnexpectedDollarInString, codeUnmatchedToken;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/dart/error/syntactic_errors.dart';
import 'package:analyzer/src/error/codes.dart';

/// An error reporter that knows how to convert a Fasta error into an analyzer
/// error.
class FastaErrorReporter {
  /// The underlying error reporter to which errors are reported.
  final ErrorReporter? errorReporter;

  /// Initialize a newly created error reporter to report errors to the given
  /// [errorReporter].
  FastaErrorReporter(this.errorReporter);

  void reportByCode(
      String? analyzerCode, int offset, int length, Message message) {
    Map<String, dynamic> arguments = message.arguments;

    String lexeme() => (arguments['lexeme'] as Token).lexeme;

    switch (analyzerCode) {
      case "ASYNC_FOR_IN_WRONG_CONTEXT":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.ASYNC_FOR_IN_WRONG_CONTEXT, offset, length);
        return;
      case "ASYNC_KEYWORD_USED_AS_IDENTIFIER":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.ASYNC_KEYWORD_USED_AS_IDENTIFIER, offset, length);
        return;
      case "AWAIT_IN_WRONG_CONTEXT":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.AWAIT_IN_WRONG_CONTEXT, offset, length);
        return;
      case "BUILT_IN_IDENTIFIER_AS_TYPE":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.BUILT_IN_IDENTIFIER_AS_TYPE,
            offset,
            length,
            [lexeme()]);
        return;
      case "CONCRETE_CLASS_WITH_ABSTRACT_MEMBER":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.CONCRETE_CLASS_WITH_ABSTRACT_MEMBER,
            offset,
            length);
        return;
      case "CONST_CONSTRUCTOR_WITH_BODY":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.CONST_CONSTRUCTOR_WITH_BODY, offset, length);
        return;
      case "CONST_NOT_INITIALIZED":
        String name = arguments['name'];
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.CONST_NOT_INITIALIZED, offset, length, [name]);
        return;
      case "DEFAULT_VALUE_IN_FUNCTION_TYPE":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.DEFAULT_VALUE_IN_FUNCTION_TYPE, offset, length);
        return;
      case "LABEL_UNDEFINED":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.LABEL_UNDEFINED,
            offset,
            length,
            [arguments['name']]);
        return;
      case "EMPTY_ENUM_BODY":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.EMPTY_ENUM_BODY, offset, length);
        return;
      case "EXPECTED_CLASS_MEMBER":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.EXPECTED_CLASS_MEMBER, offset, length);
        return;
      case "EXPECTED_EXECUTABLE":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.EXPECTED_EXECUTABLE, offset, length);
        return;
      case "EXPECTED_STRING_LITERAL":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.EXPECTED_STRING_LITERAL, offset, length);
        return;
      case "EXPECTED_TOKEN":
        errorReporter?.reportErrorForOffset(ParserErrorCode.EXPECTED_TOKEN,
            offset, length, [arguments['string']]);
        return;
      case "EXPECTED_TYPE_NAME":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.EXPECTED_TYPE_NAME, offset, length);
        return;
      case "FIELD_INITIALIZER_REDIRECTING_CONSTRUCTOR":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.FIELD_INITIALIZER_REDIRECTING_CONSTRUCTOR,
            offset,
            length);
        return;
      case "FINAL_NOT_INITIALIZED":
        String name = arguments['name'];
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.FINAL_NOT_INITIALIZED, offset, length, [name]);
        return;
      case "FINAL_NOT_INITIALIZED_CONSTRUCTOR_1":
        String name = arguments['name'];
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.FINAL_NOT_INITIALIZED_CONSTRUCTOR_1,
            offset,
            length,
            [name]);
        return;
      case "GETTER_WITH_PARAMETERS":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.GETTER_WITH_PARAMETERS, offset, length);
        return;
      case "ILLEGAL_CHARACTER":
        errorReporter?.reportErrorForOffset(
            ScannerErrorCode.ILLEGAL_CHARACTER, offset, length);
        return;
      case "INVALID_ASSIGNMENT":
        var type1 = arguments['type'];
        var type2 = arguments['type2'];
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.INVALID_ASSIGNMENT,
            offset,
            length,
            [type1, type2]);
        return;
      case "INVALID_INLINE_FUNCTION_TYPE":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.INVALID_INLINE_FUNCTION_TYPE, offset, length);
        return;
      case "INVALID_LITERAL_IN_CONFIGURATION":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.INVALID_LITERAL_IN_CONFIGURATION, offset, length);
        return;
      case "IMPORT_OF_NON_LIBRARY":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.IMPORT_OF_NON_LIBRARY, offset, length);
        return;
      case "INVALID_CAST_FUNCTION":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.INVALID_CAST_FUNCTION, offset, length);
        return;
      case "INVALID_CAST_FUNCTION_EXPR":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.INVALID_CAST_FUNCTION_EXPR, offset, length);
        return;
      case "INVALID_CAST_LITERAL_LIST":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.INVALID_CAST_LITERAL_LIST, offset, length);
        return;
      case "INVALID_CAST_LITERAL_MAP":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.INVALID_CAST_LITERAL_MAP, offset, length);
        return;
      case "INVALID_CAST_LITERAL_SET":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.INVALID_CAST_LITERAL_SET, offset, length);
        return;
      case "INVALID_CAST_METHOD":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.INVALID_CAST_METHOD, offset, length);
        return;
      case "INVALID_CAST_NEW_EXPR":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.INVALID_CAST_NEW_EXPR, offset, length);
        return;
      case "INVALID_CODE_POINT":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.INVALID_CODE_POINT, offset, length, ['\\u{...}']);
        return;
      case "INVALID_GENERIC_FUNCTION_TYPE":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.INVALID_GENERIC_FUNCTION_TYPE, offset, length);
        return;
      case "INVALID_METHOD_OVERRIDE":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.INVALID_OVERRIDE, offset, length);
        return;
      case "INVALID_MODIFIER_ON_SETTER":
        _reportByCode(CompileTimeErrorCode.INVALID_MODIFIER_ON_SETTER, message,
            offset, length);
        return;
      case "INVALID_OPERATOR_FOR_SUPER":
        _reportByCode(ParserErrorCode.INVALID_OPERATOR_FOR_SUPER, message,
            offset, length);
        return;
      case "MISSING_DIGIT":
        errorReporter?.reportErrorForOffset(
            ScannerErrorCode.MISSING_DIGIT, offset, length);
        return;
      case "MISSING_ENUM_BODY":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.MISSING_ENUM_BODY, offset, length);
        return;
      case "MISSING_FUNCTION_BODY":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.MISSING_FUNCTION_BODY, offset, length);
        return;
      case "MISSING_FUNCTION_PARAMETERS":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.MISSING_FUNCTION_PARAMETERS, offset, length);
        return;
      case "MISSING_HEX_DIGIT":
        errorReporter?.reportErrorForOffset(
            ScannerErrorCode.MISSING_HEX_DIGIT, offset, length);
        return;
      case "MISSING_IDENTIFIER":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.MISSING_IDENTIFIER, offset, length);
        return;
      case "MISSING_METHOD_PARAMETERS":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.MISSING_METHOD_PARAMETERS, offset, length);
        return;
      case "MISSING_STAR_AFTER_SYNC":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.MISSING_STAR_AFTER_SYNC, offset, length);
        return;
      case "MISSING_TYPEDEF_PARAMETERS":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.MISSING_TYPEDEF_PARAMETERS, offset, length);
        return;
      case "MULTIPLE_IMPLEMENTS_CLAUSES":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.MULTIPLE_IMPLEMENTS_CLAUSES, offset, length);
        return;
      case "NAMED_FUNCTION_EXPRESSION":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.NAMED_FUNCTION_EXPRESSION, offset, length);
        return;
      case "NAMED_PARAMETER_OUTSIDE_GROUP":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.NAMED_PARAMETER_OUTSIDE_GROUP, offset, length);
        return;
      case "NON_PART_OF_DIRECTIVE_IN_PART":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.NON_PART_OF_DIRECTIVE_IN_PART, offset, length);
        return;
      case "NON_SYNC_FACTORY":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.NON_SYNC_FACTORY, offset, length);
        return;
      case "POSITIONAL_AFTER_NAMED_ARGUMENT":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.POSITIONAL_AFTER_NAMED_ARGUMENT, offset, length);
        return;
      case "RECURSIVE_CONSTRUCTOR_REDIRECT":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.RECURSIVE_CONSTRUCTOR_REDIRECT,
            offset,
            length);
        return;
      case "RETURN_IN_GENERATOR":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.RETURN_IN_GENERATOR, offset, length);
        return;
      case "SUPER_INVOCATION_NOT_LAST":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.SUPER_INVOCATION_NOT_LAST, offset, length);
        return;
      case "SUPER_IN_REDIRECTING_CONSTRUCTOR":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.SUPER_IN_REDIRECTING_CONSTRUCTOR,
            offset,
            length);
        return;
      case "UNDEFINED_CLASS":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.UNDEFINED_CLASS, offset, length);
        return;
      case "UNDEFINED_GETTER":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.UNDEFINED_GETTER, offset, length);
        return;
      case "UNDEFINED_METHOD":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.UNDEFINED_METHOD, offset, length);
        return;
      case "UNDEFINED_SETTER":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.UNDEFINED_SETTER, offset, length);
        return;
      case "UNEXPECTED_DOLLAR_IN_STRING":
        errorReporter?.reportErrorForOffset(
            ScannerErrorCode.UNEXPECTED_DOLLAR_IN_STRING, offset, length);
        return;
      case "UNEXPECTED_TOKEN":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.UNEXPECTED_TOKEN, offset, length, [lexeme()]);
        return;
      case "UNTERMINATED_MULTI_LINE_COMMENT":
        errorReporter?.reportErrorForOffset(
            ScannerErrorCode.UNTERMINATED_MULTI_LINE_COMMENT, offset, length);
        return;
      case "UNTERMINATED_STRING_LITERAL":
        errorReporter?.reportErrorForOffset(
            ScannerErrorCode.UNTERMINATED_STRING_LITERAL, offset, length);
        return;
      case "WRONG_NUMBER_OF_PARAMETERS_FOR_SETTER":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.WRONG_NUMBER_OF_PARAMETERS_FOR_SETTER,
            offset,
            length);
        return;
      case "WRONG_SEPARATOR_FOR_POSITIONAL_PARAMETER":
        errorReporter?.reportErrorForOffset(
            ParserErrorCode.WRONG_SEPARATOR_FOR_POSITIONAL_PARAMETER,
            offset,
            length);
        return;
      case "YIELD_IN_NON_GENERATOR":
        errorReporter?.reportErrorForOffset(
            CompileTimeErrorCode.YIELD_IN_NON_GENERATOR, offset, length);
        return;
      default:
      // fall through
    }
  }

  /// Report an error based on the given [message] whose range is described by
  /// the given [offset] and [length].
  void reportMessage(Message message, int offset, int length) {
    Code code = message.code;
    int index = code.index;
    if (index > 0 && index < fastaAnalyzerErrorCodes.length) {
      var errorCode = fastaAnalyzerErrorCodes[index];
      if (errorCode != null) {
        errorReporter!.reportError(AnalysisError(errorReporter!.source, offset,
            length, errorCode, message.arguments.values.toList()));
        return;
      }
    }
    reportByCode(code.analyzerCodes?.first, offset, length, message);
  }

  void reportScannerError(
      ScannerErrorCode errorCode, int offset, List<Object>? arguments) {
    // TODO(danrubel): update client to pass length in addition to offset.
    int length = 1;
    errorReporter?.reportErrorForOffset(errorCode, offset, length, arguments);
  }

  void _reportByCode(
      ErrorCode errorCode, Message message, int offset, int length) {
    if (errorReporter != null) {
      errorReporter!.reportError(AnalysisError(errorReporter!.source, offset,
          length, errorCode, message.arguments.values.toList()));
    }
  }
}

/**
 *  Translates the given error [token] into an analyzer error and reports it
 *  using [reportError].
 */
void translateErrorToken(ErrorToken token, ReportError reportError) {
  int charOffset = token.charOffset;
  // TODO(paulberry,ahe): why is endOffset sometimes null?
  int endOffset = token.endOffset ?? charOffset;
  void _makeError(ScannerErrorCode errorCode, List<Object>? arguments) {
    if (_isAtEnd(token, charOffset)) {
      // Analyzer never generates an error message past the end of the input,
      // since such an error would not be visible in an editor.
      // TODO(paulberry,ahe): would it make sense to replicate this behavior
      // in fasta, or move it elsewhere in analyzer?
      charOffset--;
    }
    reportError(errorCode, charOffset, arguments);
  }

  Code<dynamic> errorCode = token.errorCode;
  switch (errorCode.analyzerCodes?.first) {
    case "UNTERMINATED_STRING_LITERAL":
      // TODO(paulberry,ahe): Fasta reports the error location as the entire
      // string; analyzer expects the end of the string.
      reportError(
          ScannerErrorCode.UNTERMINATED_STRING_LITERAL, endOffset - 1, null);
      return;

    case "UNTERMINATED_MULTI_LINE_COMMENT":
      // TODO(paulberry,ahe): Fasta reports the error location as the entire
      // comment; analyzer expects the end of the comment.
      reportError(ScannerErrorCode.UNTERMINATED_MULTI_LINE_COMMENT,
          endOffset - 1, null);
      return;

    case "MISSING_DIGIT":
      // TODO(paulberry,ahe): Fasta reports the error location as the entire
      // number; analyzer expects the end of the number.
      charOffset = endOffset - 1;
      return _makeError(ScannerErrorCode.MISSING_DIGIT, null);

    case "MISSING_HEX_DIGIT":
      // TODO(paulberry,ahe): Fasta reports the error location as the entire
      // number; analyzer expects the end of the number.
      charOffset = endOffset - 1;
      return _makeError(ScannerErrorCode.MISSING_HEX_DIGIT, null);

    case "ILLEGAL_CHARACTER":
      // We can safely assume `token.character` is non-`null` because this error
      // is only reported when there is a character associated with the token.
      return _makeError(ScannerErrorCode.ILLEGAL_CHARACTER, [token.character!]);

    case "UNSUPPORTED_OPERATOR":
      return _makeError(ScannerErrorCode.UNSUPPORTED_OPERATOR,
          [(token as UnsupportedOperator).token.lexeme]);

    default:
      if (errorCode == codeUnmatchedToken) {
        charOffset = token.begin!.endToken!.charOffset;
        TokenType type = token.begin!.type;
        if (type == TokenType.OPEN_CURLY_BRACKET ||
            type == TokenType.STRING_INTERPOLATION_EXPRESSION) {
          return _makeError(ScannerErrorCode.EXPECTED_TOKEN, ['}']);
        }
        if (type == TokenType.OPEN_SQUARE_BRACKET) {
          return _makeError(ScannerErrorCode.EXPECTED_TOKEN, [']']);
        }
        if (type == TokenType.OPEN_PAREN) {
          return _makeError(ScannerErrorCode.EXPECTED_TOKEN, [')']);
        }
        if (type == TokenType.LT) {
          return _makeError(ScannerErrorCode.EXPECTED_TOKEN, ['>']);
        }
      } else if (errorCode == codeUnexpectedDollarInString) {
        return _makeError(ScannerErrorCode.MISSING_IDENTIFIER, null);
      }
      throw new UnimplementedError(
          '$errorCode "${errorCode.analyzerCodes?.first}"');
  }
}

/**
 * Determines whether the given [charOffset], which came from the non-EOF token
 * [token], represents the end of the input.
 */
bool _isAtEnd(Token token, int charOffset) {
  while (true) {
    // Skip to the next token.
    token = token.next!;
    // If we've found an EOF token, its charOffset indicates where the end of
    // the input is.
    if (token.isEof) return token.charOffset == charOffset;
    // If we've found a non-error token, then we know there is additional input
    // text after [charOffset].
    if (token.type.kind != BAD_INPUT_TOKEN) return false;
    // Otherwise keep looking.
  }
}

/**
 * Used to report a scan error at the given offset.
 * The [errorCode] is the error code indicating the nature of the error.
 * The [arguments] are any arguments needed to complete the error message.
 */
typedef ReportError(
    ScannerErrorCode errorCode, int offset, List<Object>? arguments);

/**
 * The error codes used for errors detected by the scanner.
 */
class ScannerErrorCode extends ErrorCode {
  /**
   * Parameters:
   * 0: the token that was expected but not found
   */
  static const ScannerErrorCode EXPECTED_TOKEN =
      const ScannerErrorCode('EXPECTED_TOKEN', "Expected to find '{0}'.");

  /**
   * Parameters:
   * 0: the illegal character
   */
  static const ScannerErrorCode ILLEGAL_CHARACTER =
      const ScannerErrorCode('ILLEGAL_CHARACTER', "Illegal character '{0}'.");

  static const ScannerErrorCode MISSING_DIGIT =
      const ScannerErrorCode('MISSING_DIGIT', "Decimal digit expected.");

  static const ScannerErrorCode MISSING_HEX_DIGIT = const ScannerErrorCode(
      'MISSING_HEX_DIGIT', "Hexadecimal digit expected.");

  static const ScannerErrorCode MISSING_IDENTIFIER =
      const ScannerErrorCode('MISSING_IDENTIFIER', "Expected an identifier.");

  static const ScannerErrorCode MISSING_QUOTE =
      const ScannerErrorCode('MISSING_QUOTE', "Expected quote (' or \").");

  /**
   * Parameters:
   * 0: the path of the file that cannot be read
   */
  static const ScannerErrorCode UNABLE_GET_CONTENT = const ScannerErrorCode(
      'UNABLE_GET_CONTENT', "Unable to get content of '{0}'.");

  static const ScannerErrorCode UNEXPECTED_DOLLAR_IN_STRING =
      const ScannerErrorCode(
          'UNEXPECTED_DOLLAR_IN_STRING',
          "A '\$' has special meaning inside a string, and must be followed by "
              "an identifier or an expression in curly braces ({}).",
          correctionMessage: "Try adding a backslash (\\) to escape the '\$'.");

  /**
   * Parameters:
   * 0: the unsupported operator
   */
  static const ScannerErrorCode UNSUPPORTED_OPERATOR = const ScannerErrorCode(
      'UNSUPPORTED_OPERATOR', "The '{0}' operator is not supported.");

  static const ScannerErrorCode UNTERMINATED_MULTI_LINE_COMMENT =
      const ScannerErrorCode(
          'UNTERMINATED_MULTI_LINE_COMMENT', "Unterminated multi-line comment.",
          correctionMessage: "Try terminating the comment with '*/', or "
              "removing any unbalanced occurrences of '/*'"
              " (because comments nest in Dart).");

  static const ScannerErrorCode UNTERMINATED_STRING_LITERAL =
      const ScannerErrorCode(
          'UNTERMINATED_STRING_LITERAL', "Unterminated string literal.");

  /**
   * Initialize a newly created error code to have the given [name]. The message
   * associated with the error will be created from the given [problemMessage]
   * template. The correction associated with the error will be created from the
   * given [correctionMessage] template.
   */
  const ScannerErrorCode(String name, String problemMessage,
      {String? correctionMessage})
      : super(
          correctionMessage: correctionMessage,
          problemMessage: problemMessage,
          name: name,
          uniqueName: 'ScannerErrorCode.$name',
        );

  @override
  ErrorSeverity get errorSeverity => ErrorSeverity.ERROR;

  @override
  ErrorType get type => ErrorType.SYNTACTIC_ERROR;
}
