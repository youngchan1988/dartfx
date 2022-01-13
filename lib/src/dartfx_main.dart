// TODO: Put public facing types in this file.

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/src/string_source.dart';
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

ProgramImpl parseProgram({required String content}) {
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
  var program = parseProgram(content: expression);
  var visitor = AstRuntimeVisitor();
  var ast = program.accept(visitor);
  var executor = DefaultAstRuntimeExecutor(envValue: envValue);
  var astContext = AstContext();
  return executor.execute(astContext, runtime.Program.fromAst(ast)!.body!);
}

dynamic executeExpressionWithEnv({required String expression, Map? envs}) {
  var program = parseProgram(content: expression);
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

dynamic fx(String expression) {
  return executeExpression(expression: expression);
}

dynamic fxWithEnvs(String expression, Map envs) {
  return executeExpressionWithEnv(expression: expression, envs: envs);
}

dynamic fxAssignment(String expression, Map envs,
    {void Function(List<String>)? leftEnvFields}) {
  var program = parseProgram(content: expression);

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
