// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';
import 'package:dartfx/src/util/logger.dart';

class IterableResolver extends AstResolver {
  static const _tag = "IterableParser";

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode?>? arguments}) {
    if (target == null) {
      return null;
    }
    var realTarget = target as Iterable;
    switch (property) {
      case "toList":
        return realTarget.toList();
      case "reduce":
        var arg = arguments![0];
        if (arg is FunctionExpression) {
          var func = AstFunction.fromAstNode(astContext, executor, arg);
          realTarget = realTarget.cast<dynamic>();
          return realTarget
              .reduce((value, element) => func?.call(params: [value, element]));
        } else {
          var func = executor.execute(astContext, arg);
          return realTarget.reduce(func);
        }

      case "map":
        var arg = arguments![0];
        if (arg is FunctionExpression) {
          var func = AstFunction.fromAstNode(astContext, executor, arg);
          return realTarget.map((element) => func?.call(params: [element]));
        } else {
          var func = executor.execute(astContext, arg);
          return realTarget.map(func);
        }
      case "where":
        var arg = arguments![0];
        if (arg is FunctionExpression) {
          var func = AstFunction.fromAstNode(astContext, executor, arg);
          return realTarget.where((element) => func?.call(params: [element]));
        } else {
          var func = executor.execute(astContext, arg);
          return realTarget.where(func);
        }
      case 'first':
        return realTarget.first;
      case 'last':
        return realTarget.last;
      case 'single':
        return realTarget.single;
      case 'isNotEmpty':
        return realTarget.isNotEmpty;
      case 'isEmpty':
        return realTarget.isEmpty;
      case 'length':
        return realTarget.length;
      case 'elementAt':
        return realTarget
            .elementAt(executor.execute(astContext, arguments!.first));
      case 'contains':
        return realTarget
            .contains(executor.execute(astContext, arguments!.first));
      case 'forEach':
        var arg = arguments![0];
        if (arg is FunctionExpression) {
          var func = AstFunction.fromAstNode(astContext, executor, arg);
          return realTarget.forEach((element) => func?.call(params: [element]));
        } else {
          var func = executor.execute(astContext, arg);
          return realTarget.forEach(func);
        }
      case 'join':
        if (arguments?.isNotEmpty == true) {
          var joinStr = executor.execute(astContext, arguments![0]);
          return target.join(joinStr);
        }
        logError(_tag, "list join方法参数不为空");
        break;
      default:
        logError(_tag, "undefine method $property for $target");
    }
    return null;
  }

  @override
  bool canResolve(target, {String? property}) {
    return target is Iterable;
  }
}
