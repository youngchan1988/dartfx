import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

///
/// Author: YoungChan
/// Date: 2022-01-13 17:20:54
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-13 17:20:54
/// Description: INTCEIL 函数，返回参数向上取整的值
/// `int INTCEIL(num a)`
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

class FuncIntceilResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'INTCEIL';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.isNotEmpty == true) {
      var arg = arguments!.first;
      var value = executor.execute(astContext, arg);
      if (value is num) {
        return value.ceil();
      } else {
        throw 'Function INTCEIL must have a numeric argument';
      }
    } else {
      throw 'Function INTCEIL invalid arguments';
    }
  }
}
