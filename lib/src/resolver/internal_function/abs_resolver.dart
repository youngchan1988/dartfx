import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

///
/// Author: YoungChan
/// Date: 2022-01-13 12:36:36
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-13 12:37:19
/// Description: ABS 函数，返回参数绝对值
/// `num ABS(num a)`
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

class FuncAbsResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'ABS';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.isNotEmpty == true) {
      var arg = arguments!.first;
      var value = executor.execute(astContext, arg);
      if (value is num) {
        return value.abs();
      } else {
        throw 'Function ABS must have a numeric argument';
      }
    } else {
      throw 'Function ABS invalid arguments';
    }
  }
}
