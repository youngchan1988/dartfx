import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/visitor.dart';

///
/// Author: YoungChan
/// Date: 2022-01-09 00:17:49
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-09 00:17:49
/// Description: description
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

void main() {
  var parseResult = parseString(content: "var a = MAX(order.number, 100);");
  var compilationUnit = parseResult.unit;
  var visitor = GeneralizingAstVisitor();
  var ast = compilationUnit.accept(visitor);
  print('Output ast: $ast');
}
