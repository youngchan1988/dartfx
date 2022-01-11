import 'package:dartfx/dartfx.dart';
import 'package:dartfx/src/ast_impl/ast_runtime_visitor.dart';
import 'package:args/args.dart';

///
/// Author: YoungChan
/// Date: 2022-01-11 15:28:54
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-11 15:28:54
/// Description: description
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addFlag('expression', negatable: false, abbr: 'e');

  ArgResults argResults = parser.parse(arguments);
  var expression = argResults.rest.first;

  // var program = parseProgram(
  //     content:
  //         '\$43858.accountingVoucherType\$=\$43859.unitName\$+\$43859.currency\$+\"number\"');
  // var program = parseProgram(content: expression);

  // // var program = parseProgram(content: 'a=n.x + n.y + "hello"');
  // var visitor = AstRuntimeVisitor();
  // var ast = program.accept(visitor);
  // var result = executeExpression(
  //     expression: expression,
  //     envValue: (env) {
  //       return env.substring(1, env.length - 1);
  //     });
  var result = fxWithEnvs(expression, {
    "43858": {"unitName": "单位"},
    "43859": {"currency": "100", "unitName": "人民币"}
  });
  print('Fx output: $result');
}
