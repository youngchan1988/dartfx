// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/src/string_source.dart';
import 'package:dartfx/dartfx.dart';
import 'package:dartfx/src/util/logger.dart';
import 'ast_impl/ast.dart';
import 'ast_impl/ast_runtime_visitor.dart';
import 'lexer/expression_lexer.dart';
import 'lexer/tokens/token.dart';
import 'parser/ast_builder.dart';
import 'parser/parser.dart';
import 'runtime/ast_runtime.dart';
import 'runtime/ast_runtime_node.dart' as runtime;

const _tag = "dartfx";

ProgramImpl _parseProgram({required String content}) {
  var source = StringSource(content, '');
  var errorCollector = RecordingErrorListener();
  var lexer = ExpressionLexer(expression: content);
  var token = lexer.scan();
  var astBuilder = AstBuilder(
      ErrorReporter(
        errorCollector,
        source,
        isNonNullableByDefault: false,
      ),
      true);
  var parser = Parser(astBuilder);
  token = parser.parseProgram(token);
  return astBuilder.pop() as ProgramImpl;
}

dynamic _executeExpression(
    {required String expression, GetEnvValue? onGetEnvValue}) {
  if (expression.isEmpty) {
    return '';
  }
  var program = _parseProgram(content: expression);
  var visitor = AstRuntimeVisitor();
  var ast = program.accept(visitor);
  var executor = DefaultAstRuntimeExecutor(onGetEnvValue: (envVar) {
    if (envVar.startsWith('\$') && envVar.endsWith('\$')) {
      var varStr = envVar.substring(1, envVar.length - 1);
      return onGetEnvValue?.call(varStr);
    } else {
      warn(tag: _tag, message: "Unkown environment variable: $envVar");
      return null;
    }
  });
  var astContext = AstContext();
  return executor.execute(astContext, runtime.Program.fromAst(ast)!.body!);
}

dynamic _executeExpressionWithEnv(
    {required String expression, Map? envValues}) {
  return _executeExpression(
      expression: expression,
      onGetEnvValue: (envVar) {
        if (envValues?.isNotEmpty == true) {
          return _parseEnvValue(envVar, envValues!);
        } else {
          return null;
        }
      });
}

///Read environment variable from values set.
///
/// envVar: eg: `$a.b$`.
///
dynamic _parseEnvValue(String envVar, Map envValues) {
  if (envValues.isNotEmpty && envVar.isNotEmpty) {
    var fields = envVar.split(".");
    dynamic value = envValues;
    for (var f in fields) {
      value = value[f];
    }
    return value;
  } else {
    return null;
  }
}

/// If there is a function witch the internal functions doesn't have. You can custom
/// your own function by set a [FunctionResolver].
///
void fxSetFunctionResolver(FunctionResolver functionResolver) {
  Resolver.instance.functionApply = functionResolver;
}

/// Run expression and return the result.
///
/// onGetEnvValue: Environment value callback function.
///
dynamic fx(String expression, {GetEnvValue? onGetEnvValue}) {
  return _executeExpression(
      expression: expression, onGetEnvValue: onGetEnvValue);
}

///
/// Run expression and return the result.
///
/// envValues: Environment values set. If the expression contains a variable `$a.b$`. Then
///       you should give a values set like `{"a": {"b": something}}`.
///
dynamic fxWithEnvs(String expression, Map envValues) {
  return _executeExpressionWithEnv(
      expression: expression, envValues: envValues);
}

///
/// Run assignment expression and return the right side value.
///
/// expression: Assignment expression，eg: `$a.b$=1+2+3`.
/// envValues: Environment values set. If the expression contains a variable `$a.b$`. Then
///       you should give a values set like `{"a": {"b": something}}`.
/// leftEnvs: Used for [jsfxAssignment] in `jsfx.dart`.
///
dynamic fxAssignment(String expression, Map envValues,
    {void Function(List<String>)? leftEnvs}) {
  if (expression.isEmpty) {
    return null;
  }
  var program = _parseProgram(content: expression);

  var visitor = AstRuntimeVisitor();
  var ast = program.accept(visitor);

  var executor = DefaultAstRuntimeExecutor(onGetEnvValue: (envVar) {
    if (envVar.startsWith('\$') && envVar.endsWith('\$')) {
      var varStr = envVar.substring(1, envVar.length - 1);
      return _parseEnvValue(varStr, envValues);
    } else {
      warn(tag: _tag, message: "Unkown environment variable: $envVar");
      return null;
    }
  });
  var runtimeNode = runtime.Program.fromAst(ast)!.body!;
  if (runtimeNode is! runtime.AssignmentExpression ||
      (runtimeNode.operator != '=' &&
          runtimeNode.operator != '+=' &&
          runtimeNode.operator != '-=' &&
          runtimeNode.operator != '*=' &&
          runtimeNode.operator != '/=' &&
          runtimeNode.operator != '~/=' &&
          runtimeNode.operator != '%=' &&
          runtimeNode.operator != '&=' &&
          runtimeNode.operator != '|=' &&
          runtimeNode.operator != '^=' &&
          runtimeNode.operator != '>>=' &&
          runtimeNode.operator != '<<=')) {
    error(tag: _tag, message: 'Unsupport assignment expression: $expression');
    return null;
  }
  if (runtimeNode.left is! runtime.StringLiteral ||
      !executor
          .isEnvString((runtimeNode.left as runtime.StringLiteral).value)) {
    warn(tag: _tag, message: 'Assignment left is not env variable');
    return null;
  }
  var astContext = AstContext();
  dynamic rightValue = executor.execute(astContext, runtimeNode.right);

  var leftEnvVar = (runtimeNode.left as runtime.StringLiteral).value as String;
  if (leftEnvVar.startsWith('\$') && leftEnvVar.endsWith('\$')) {
    leftEnvVar = leftEnvVar.substring(1, leftEnvVar.length - 1);
  } else {
    warn(tag: _tag, message: 'Assignment left is not env variable');
    return null;
  }
  var leftValue = _parseEnvValue(leftEnvVar, envValues);
  var fields = leftEnvVar.split(".");
  leftEnvs?.call(fields);
  dynamic value = envValues;
  for (var i = 0; i < fields.length - 1; i++) {
    value = value[fields[i]];
  }
  if (rightValue != null) {
    if (leftValue != null) {
      switch (runtimeNode.operator) {
        case '+=':
          rightValue = leftValue + rightValue;
          break;
        case '-=':
          rightValue = leftValue - rightValue;
          break;
        case '*=':
          rightValue = leftValue * rightValue;
          break;
        case '%=':
          rightValue = leftValue % rightValue;
          break;
        case '&=':
          rightValue = leftValue & rightValue;
          break;
        case '|=':
          rightValue = leftValue | rightValue;
          break;
        case '^=':
          rightValue = leftValue ^ rightValue;
          break;
        case '>>=':
          rightValue = leftValue >> rightValue;
          break;
        case '<<=':
          rightValue = leftValue << rightValue;
          break;
      }
    } else {
      warn(tag: _tag, message: 'Assignment right side is null');
    }

    value[fields.last] = rightValue;
  } else {
    warn(tag: _tag, message: 'Assignment right side is null');
  }

  return rightValue;
}

Token parseToken(String expression) {
  var lexer = ExpressionLexer(expression: expression);
  return lexer.scan();
}

List<AnalysisError>? analysisExpression(String expression) {
  var source = StringSource(expression, '');
  var errorCollector = RecordingErrorListener();

  var token = parseToken(expression);

  var astBuilder = AstBuilder(
      ErrorReporter(
        errorCollector,
        source,
        isNonNullableByDefault: false,
      ),
      true);
  var parser = Parser(astBuilder);
  parser.parseProgram(token);
  return errorCollector.errors;
}
