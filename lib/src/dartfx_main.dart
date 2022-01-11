// TODO: Put public facing types in this file.

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/src/string_source.dart';
import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/util/logger.dart';
import 'ast_impl/ast.dart';
import 'ast/line_info.dart';
import 'ast/results.dart';
import 'ast_impl/ast_runtime_visitor.dart';
import 'ast_impl/results.dart';
import 'lexer/expression_lexer.dart';
import 'parser/ast_builder.dart';
import 'parser/parser.dart';
import 'runtime/ast_runtime.dart';
import 'runtime/ast_runtime_node.dart' as runtime;

const _tag = "dartfx";

/// Returns the result of parsing the given [content] as a compilation unit.
///
/// If a [featureSet] is provided, it will be the default set of features that
/// will be assumed by the parser.
///
/// If a [path] is provided, it will be used as the name of the file when
/// reporting errors.
///
/// If [throwIfDiagnostics] is `true` (the default), then if any diagnostics are
/// produced because of syntactic errors in the [content] an `ArgumentError`
/// will be thrown.  This behavior is not intended as a way for the client to
/// find out about errors--it is intended to avoid causing problems for naive
/// clients that might not be thinking about the possibility of parse errors
/// (and might therefore make assumptions about the returned AST that don't hold
/// in the presence of parse errors).  Clients interested in details about parse
/// errors should pass `false` and check `result.errors` to determine what parse
/// errors, if any, have occurred.
ParseStringResult parseString({required String content}) {
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

  parser.parseUnit(token);
  var unit = astBuilder.pop() as CompilationUnitImpl;
  unit.lineInfo = LineInfo(lexer.scanner.lineStarts);

  ParseStringResult result =
      ParseStringResultImpl(content, unit, errorCollector.errors);
  if (result.errors.isNotEmpty) {
    throw ArgumentError('Content produced diagnostics when parsed');
  }
  return result;
}

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

dynamic executeExpressionWithEnv(
    {required String expression, Map<String, dynamic>? envs}) {
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

dynamic fxWithEnvs(String expression, Map<String, dynamic> envs) {
  return executeExpressionWithEnv(expression: expression, envs: envs);
}

void fxAssignment(String expression, Map<String, dynamic> envs) {
  var program = parseProgram(content: expression);

  var visitor = AstRuntimeVisitor();
  var ast = program.accept(visitor);

  var executor = DefaultAstRuntimeExecutor(envValue: (envValue) {
    return parseEnvValue(envValue, envs);
  });
  var runtimeNode = runtime.Program.fromAst(ast)!.body!;
  if (runtimeNode is! runtime.AssignmentExpression ||
      (runtimeNode.operator != '=')) {
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
  var rightValue = executor.execute(astContext, runtimeNode.right);

  var leftEnvValue =
      (runtimeNode.left as runtime.StringLiteral).value as String;
  leftEnvValue = leftEnvValue.substring(1, leftEnvValue.length - 1);
  var fields = leftEnvValue.split(".");
  dynamic value = envs;
  for (var i = 0; i < fields.length - 1; i++) {
    value = value[fields[i]];
  }
  value[fields[fields.length - 1]] = rightValue;
}

///读取变量值
dynamic parseEnvValue(String envValue, Map<String, dynamic> envs) {
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
