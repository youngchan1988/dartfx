// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/src/string_source.dart';
import 'package:dartfx/dartfx.dart';
import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/util/logger.dart';
import 'ast_impl/ast.dart';
import 'ast_impl/ast_runtime_visitor.dart';
import 'lexer/expression_lexer.dart';
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

dynamic executeExpression(
    {required String expression, dynamic Function(String)? envValue}) {
  var program = _parseProgram(content: expression);
  var visitor = AstRuntimeVisitor();
  var ast = program.accept(visitor);
  var executor = DefaultAstRuntimeExecutor(envValue: envValue);
  var astContext = AstContext();
  return executor.execute(astContext, runtime.Program.fromAst(ast)!.body!);
}

dynamic executeExpressionWithEnv({required String expression, Map? envs}) {
  var program = _parseProgram(content: expression);
  var visitor = AstRuntimeVisitor();
  var ast = program.accept(visitor);
  var executor = DefaultAstRuntimeExecutor(envValue: (envValue) {
    if (envs?.isNotEmpty == true) {
      return parseEnvValue(envValue, envs!);
    } else {
      return null;
    }
  });
  var astContext = AstContext();
  return executor.execute(astContext, runtime.Program.fromAst(ast)!.body!);
}

///设置自定义函数回调，初始化时调用一次
void fxSetFunctionResolver(FunctionResolver functionResolver) {
  Resolver.instance.functionApply = functionResolver;
}

// 运行公式表达式并返回结果
dynamic fx(String expression) {
  return executeExpression(expression: expression);
}

///
/// 运行包含变量声明（$...$）的公式表达式，并返回结果
/// expression: 公式表达式
/// envs: 变量值对象{}
///
dynamic fxWithEnvs(String expression, Map envs) {
  return executeExpressionWithEnv(expression: expression, envs: envs);
}

///
/// 运行包含变量声明（$...$）的赋值表达式，赋值的结果更新在`envs`中
/// expression: 赋值公式表达式，如：$a.b$=1+2+3
/// envs: 变量值对象{}
///
dynamic fxAssignment(String expression, Map envs,
    {void Function(List<String>)? leftEnvFields}) {
  var program = _parseProgram(content: expression);

  var visitor = AstRuntimeVisitor();
  var ast = program.accept(visitor);

  var executor = DefaultAstRuntimeExecutor(envValue: (envValue) {
    return parseEnvValue(envValue, envs);
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
    logWarn(_tag, 'Exprssion is not assignment');
    return;
  }
  if (runtimeNode.left is! runtime.StringLiteral ||
      !executor
          .isEnvString((runtimeNode.left as runtime.StringLiteral).value)) {
    logWarn(_tag, 'Assignment left is not env variable');
    return;
  }
  var astContext = AstContext();
  dynamic rightValue = executor.execute(astContext, runtimeNode.right);

  var leftEnvValue =
      (runtimeNode.left as runtime.StringLiteral).value as String;
  var leftValue = parseEnvValue(leftEnvValue, envs);

  leftEnvValue = leftEnvValue.substring(1, leftEnvValue.length - 1);
  var fields = leftEnvValue.split(".");
  leftEnvFields?.call(fields);
  dynamic value = envs;
  for (var i = 0; i < fields.length - 1; i++) {
    value = value[fields[i]];
  }

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
  value[fields.last] = rightValue;
  return rightValue;
}

///读取变量值
dynamic parseEnvValue(String envValue, Map envs) {
  if (envs.isNotEmpty && envValue.length > 2) {
    envValue = envValue.substring(1, envValue.length - 1);
    var fields = envValue.split(".");
    dynamic value = envs;
    for (var i = 0; i < fields.length; i++) {
      value = value[fields[i]];
    }
    return value;
  } else {
    return null;
  }
}
