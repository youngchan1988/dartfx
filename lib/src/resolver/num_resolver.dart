import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

///
///Author: YoungChan
///Date: 2020-07-13 17:41:38
///LastEditors: YoungChan
///LastEditTime: 2020-10-20 14:54:33
///Description: 数值解析
///

class IntResolver extends AstResolver {
  @override
  dynamic resolve(
    AstContext astContext,
    AstRuntimeExecutor executor,
    target, {
    String? property,
    List<AstRuntimeNode?>? arguments,
  }) {
    if (target is int) {
      switch (property) {
        case 'toString':
          return target.toString();
        case 'toDouble':
          return target.toDouble();
      }
    }
    return target;
  }

  @override
  bool canResolve(target, {String? property}) {
    return target is int;
  }
}

///double 解析
///* double.maxFinite
///* double.infinity
///* double.minPositive
///* double.negativeInfinity
///* double.nan
///* toString
///* toInt
///* toDouble
class DoubleResolver extends AstResolver {
  @override
  dynamic resolve(
    AstContext astContext,
    AstRuntimeExecutor executor,
    target, {
    String? property,
    List<AstRuntimeNode?>? arguments,
  }) {
    if (target == "double") {
      switch (property) {
        case "maxFinite":
          return double.maxFinite;
        case "infinity":
          return double.infinity;
        case "minPositive":
          return double.minPositive;
        case "negativeInfinity":
          return double.negativeInfinity;
        case "nan":
          return double.nan;
      }
    } else if (target is double) {
      switch (property) {
        case 'toString':
          return target.toString();
        case 'toInt':
          return target.toInt();
        case "toDouble":
          return target.toDouble();
      }
    }
    return target;
  }

  @override
  bool canResolve(target, {String? property}) =>
      target == "double" || target is double;
}
