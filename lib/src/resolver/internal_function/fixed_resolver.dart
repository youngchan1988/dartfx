import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';
import 'package:dartfx/src/util/util.dart';

///
/// Author: YoungChan
/// Date: 2022-01-13 13:12:01
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-13 13:12:02
/// Description: FIXED 函数，返回浮点参数按指定位数四舍五入的值的字符串
/// `String FIXED(num a, int digit)`
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

class FuncFixedResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'FIXED';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.length == 2) {
      var argNumber = arguments!.first;
      var argDigit = arguments[1];
      var numberValue = executor.execute(astContext, argNumber);
      var digitValue = executor.execute(astContext, argDigit);
      if (numberValue is num && digitValue is int) {
        return formatNum(numberValue, digits: digitValue);
      } else {
        throw 'Function FIXED must have numeric arguments';
      }
    } else {
      throw 'Function FIXED invalid arguments';
    }
  }
}
