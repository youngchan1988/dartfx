import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';
import 'package:dartfx/src/util/logger.dart';

///
///Author: YoungChan
///Date: 2020-07-07 14:53:38
///LastEditors: YoungChan
///LastEditTime: 2020-10-28 14:30:41
///Description: Map 解析
///

class MapResolver extends AstResolver {
  static const _tag = "MapParser";

  @override
  dynamic resolve(
    AstContext astContext,
    AstRuntimeExecutor executor,
    target, {
    String? property,
    List<AstRuntimeNode?>? arguments,
  }) {
    if (target is Map) {
      switch (property) {
        case "length":
          return target.length;
        case 'keys':
          return target.keys;
        case 'values':
          return target.values;
        case 'isEmpty':
          return target.isEmpty;
        case 'isNotEmpty':
          return target.isNotEmpty;
        case 'addAll':
          if (arguments?.isNotEmpty == true) {
            var value = executor.execute(astContext, arguments![0]);
            if (value != null && value is Map) {
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
          break;
        case 'clear':
          target.clear();
          break;
        case 'containsKey':
          if (arguments?.isNotEmpty == true) {
            var value = executor.execute(astContext, arguments![0]);
            if (value != null) {
              return target.containsKey(value);
            }
          }
          return false;
        case 'containsValue':
          if (arguments?.isNotEmpty == true) {
            var value = executor.execute(astContext, arguments![0]);
            if (value != null) {
              return target.containsValue(value);
            }
          }
          return false;
        case "map":
          var arg = arguments![0];
          if (arg is FunctionExpression) {
            var func = AstFunction.fromAstNode(astContext, executor, arg);
            return target.map((key, value) => func?.call(params: [key, value]));
          } else {
            var func = executor.execute(astContext, arg);
            return target.map(func);
          }
        case "where":
          var arg = arguments![0];
          if (arg is FunctionExpression) {
            var func = AstFunction.fromAstNode(astContext, executor, arg);
            return target
                .removeWhere((key, value) => func?.call(params: [key, value]));
          } else {
            var func = executor.execute(astContext, arg);
            return target.removeWhere(func);
          }
        case "forEach":
          var arg = arguments![0];
          if (arg is FunctionExpression) {
            var func = AstFunction.fromAstNode(astContext, executor, arg);
            return target.forEach((key, value) {
              func?.call(params: [key, value]);
            });
          } else {
            var func = executor.execute(astContext, arg);
            return target.forEach(func);
          }
        default:
          logError(_tag, "undefined method $property for $target");
      }
    } else if (target == 'Map') {
      if (property == null) {
        return Map();
      } else {
        switch (property) {
          case 'from':
            var arg = arguments![0];
            return Map.from(executor.execute(astContext, arg));
          case 'castFrom':
            var arg = arguments![0];
            return Map.castFrom(executor.execute(astContext, arg));
          case 'of':
            var arg = arguments![0];
            return Map.of(executor.execute(astContext, arg));
          default:
            logError(_tag, "undefined method $property for $target");
        }
      }
    }

    return null;
  }

  @override
  bool canResolve(target, {String? property}) {
    return target is Map || target == 'Map';
  }
}
