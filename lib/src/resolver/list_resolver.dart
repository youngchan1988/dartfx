// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';
import 'package:dartfx/src/util/logger.dart';

class ListResolver extends AstResolver {
  static const _tag = "ListParser";

  @override
  dynamic resolve(
    AstContext astContext,
    AstRuntimeExecutor executor,
    target, {
    String? property,
    List<AstRuntimeNode?>? arguments,
  }) {
    if (target is List) {
      switch (property) {
        case 'first':
          return target.first;
        case 'last':
          return target.last;
        case 'single':
          return target.single;
        case 'length':
          return target.length;
        case 'isEmpty':
          return target.isEmpty;
        case 'isNotEmpty':
          return target.isNotEmpty;
        case 'add':
          if (arguments?.isNotEmpty == true) {
            var value = executor.execute(astContext, arguments![0]);
            if (value != null) {
              target.add(value);
            }
          }

          break;
        case 'addAll':
          if (arguments?.isNotEmpty == true) {
            var value = executor.execute(astContext, arguments![0]);
            if (value != null && value is List) {
              target.addAll(value);
            }
          }
          break;
        case 'remove':
          if (arguments?.isNotEmpty == true) {
            var value = executor.execute(astContext, arguments![0]);
            if (value != null) {
              return target.remove(value);
            }
          }
          return false;
        case 'removeAt':
          if (arguments?.isNotEmpty == true) {
            var value = executor.execute(astContext, arguments![0]);
            if (value != null && value is int) {
              return target.removeAt(value);
            }
          }
          return false;
        case 'sublist':
          if (arguments?.isNotEmpty == true) {
            var start = executor.execute(astContext, arguments![0]);
            if (arguments.length == 2) {
              var end = executor.execute(astContext, arguments[1]);
              return target.sublist(start, end);
            } else {
              return target.sublist(start);
            }
          }
          return false;
        case 'removeLast':
          return target.removeLast();
        case 'clear':
          target.clear();
          break;
        case 'insert':
          if (arguments?.isNotEmpty == true && arguments!.length == 2) {
            var index = executor.execute(astContext, arguments[0]);
            var value = executor.execute(astContext, arguments[1]);
            if (value != null) {
              target.insert(index, value);
            }
          }
          break;
        case 'insertAll':
          if (arguments?.isNotEmpty == true && arguments!.length == 2) {
            var index = executor.execute(astContext, arguments[0]);
            var value = executor.execute(astContext, arguments[1]);
            if (value != null && value is List) {
              target.insertAll(index, value);
            }
          }

          break;
        case 'indexOf':
          if (arguments?.isNotEmpty == true) {
            var value = executor.execute(astContext, arguments![0]);
            if (value != null) {
              return target.indexOf(value);
            }
          }
          return -1;
        case 'lastIndexOf':
          if (arguments?.isNotEmpty == true) {
            var value = executor.execute(astContext, arguments![0]);
            if (value != null) {
              return target.lastIndexOf(value);
            }
          }
          return -1;
        case 'contains':
          if (arguments?.isNotEmpty == true) {
            var value = executor.execute(astContext, arguments![0]);
            if (value != null) {
              return target.contains(value);
            }
          }
          return false;
        case 'join':
          if (arguments?.isNotEmpty == true) {
            var joinStr = executor.execute(astContext, arguments![0]);
            return target.join(joinStr);
          }
          logError(_tag, "list join方法参数不为空");
          break;
        case "map":
          var arg = arguments![0];
          if (arg is FunctionExpression) {
            var func = AstFunction.fromAstNode(astContext, executor, arg);
            return target.map((e) => func?.call(params: [e]));
          } else {
            var func = executor.execute(astContext, arg);
            return target.map(func);
          }
        case "fold":
          var value = executor.execute(astContext, arguments![0]);
          var arg = arguments[1];
          if (arg is FunctionExpression) {
            var func = AstFunction.fromAstNode(astContext, executor, arg);
            target = target.cast<dynamic>();
            var ret = target.fold(
              value,
              (previousValue, element) =>
                  func?.call(params: [previousValue, element]),
            );
            logDebug('ret', 'ret = $ret');
            return ret;
          } else {
            var func = executor.execute(astContext, arg);
            return target.fold(value, func);
          }
        case "where":
          var arg = arguments![0];
          if (arg is FunctionExpression) {
            var func = AstFunction.fromAstNode(astContext, executor, arg);
            return target.where((element) => func?.call(params: [element]));
          } else {
            var func = executor.execute(astContext, arg);
            return target.where(func);
          }
        case "forEach":
          var arg = arguments![0];
          if (arg is FunctionExpression) {
            var func = AstFunction.fromAstNode(astContext, executor, arg);
            return target.forEach((element) {
              func?.call(params: [element]);
            });
          } else {
            var func = executor.execute(astContext, arg);
            return target.forEach(func);
          }
        case 'reversed':
          return target.reversed;
        case 'elementAt':
          return target
              .elementAt(executor.execute(astContext, arguments!.first));
        case 'toList':
          return target.toList();
        case 'toString':
          return target.toString();
        default:
          logError(_tag, "undefine method $property for $target");
      }
    }
    return null;
  }

  @override
  bool canResolve(target, {String? property}) {
    return target is List;
  }
}
