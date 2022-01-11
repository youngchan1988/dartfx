import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';
import 'package:dartfx/src/util/logger.dart';

///
///Author: YoungChan
///Date: 2020-07-07 14:53:38
///LastEditors: YoungChan
///LastEditTime: 2020-10-13 17:43:18
///Description: String 解析
///

class StringResolver extends AstResolver {
  static const _tag = "StringParser";

  @override
  dynamic resolve(
    AstContext astContext,
    AstRuntimeExecutor executor,
    target, {
    String? property,
    List<AstRuntimeNode?>? arguments,
  }) {
    if (target == null) {
      return null;
    }
    if (target is String) {
      switch (property) {
        case 'length':
          return target.length;
        case 'isEmpty':
          return target.isEmpty;
        case 'isNotEmpty':
          return target.isNotEmpty;
        case 'contains':
          if (arguments?.isNotEmpty == true) {
            var value = executor.execute(astContext, arguments![0]);
            if (value != null) {
              return target.contains(value);
            }
          }
          return false;
        case 'toString':
          return target.toString();
        case 'split':
          if (arguments?.isNotEmpty == true) {
            var value = executor.execute(astContext, arguments![0]);
            if (value != null) {
              return target.split(value);
            }
          }
          break;
        default:
          logError(_tag, "Undefined property $property for $target");
      }
    }
    return null;
  }

  @override
  bool canResolve(target, {String? property}) {
    return target is String &&
        (["length", "isEmpty", "isNotEmpty", "contains", 'toString', 'split']
            .contains(property));
  }
}
