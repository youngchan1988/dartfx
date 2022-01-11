import 'package:dartfx/dartfx.dart';
import 'dart:js' as js;

void main() {
  // var result = fx("1+(2+3)*7-6/2");
  // print('Fx result: $result');
  js.context['fx'] = fx;
}

String fx(String expression) {
  // return executeExpression(expression: "3>0? 'yes':'no'").toString();
  return executeExpression(expression: expression).toString();
}
