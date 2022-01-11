import 'package:dartfx/dartfx.dart';
import 'dart:js' as js;

void main() {
  js.context['fx'] = fx;
}

dynamic fx(String expression) {
  return executeExpression(expression: expression);
}
