import 'package:dartfx/dartfx.dart';
import 'dart:js' as js;

void main() {
  // Token? token = ExpressionLexer(expression: "!(-2 > 0)").scan();
  // while (token != null && !token.isEof) {
  //   print("Token: ${token.toString()}\n");
  //   token = token.next;
  // }

  // var parseResult = parseString(content: "MAX(order.number, 100)");
  // var compilationUnit = parseResult.unit;
  // var visitor = GeneralizingAstVisitor();
  // var ast = compilationUnit.accept(visitor);
  // var exp = parseProgram(content: "3>0? 'yes':'no'");
  // var visitor = AstRuntimeVisitor();
  // var ast = exp.accept(visitor);
  // print('Output ast: $ast');
  // var result = executeExpression(expression: "1+(2+3)*7-6/2");
  // var result = run("1+(2+3)*7-6/2");
  // print('Fx result: $result');
  js.context['fx'] = fx;
}

String fx(String expression) {
  // return executeExpression(expression: "3>0? 'yes':'no'").toString();
  return executeExpression(expression: expression).toString();
}
