import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

///
/// Author: YoungChan
/// Date: 2022-01-13 12:26:15
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-13 12:26:15
/// Description: MIN 函数，返回参数中的最小值
/// `num MIN(num a, num b, [num c, ...])`
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

class FuncMinResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'MIN';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.isNotEmpty == true) {
      double result = double.maxFinite;
      for (var arg in arguments!) {
        var value = executor.execute(astContext, arg);
        if (value is num) {
          result = result < value.toDouble() ? result : value.toDouble();
        } else {
          throw 'Function MIN must have numeric arguments';
        }
      }
      return result;
    } else {
      throw 'Function MIN invalid arguments';
    }
  }
}
