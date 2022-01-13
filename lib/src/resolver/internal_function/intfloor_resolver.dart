import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

///
/// Author: YoungChan
/// Date: 2022-01-13 13:17:15
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-13 13:17:15
/// Description: INTFLOOR 函数，返回参数向下取整的值
/// `int INTFLOOR(num a)`
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

class FuncIntfloorResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'INTFLOOR';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.isNotEmpty == true) {
      var arg = arguments!.first;
      var value = executor.execute(astContext, arg);
      if (value is num) {
        return value.floor();
      } else {
        throw 'Function INTFLOOR must have a numeric argument';
      }
    } else {
      throw 'Function INTFLOOR invalid arguments';
    }
  }
}
