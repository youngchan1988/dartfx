import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';
import 'package:dartfx/src/util/util.dart';

///
/// Author: YoungChan
/// Date: 2022-01-13 12:44:22
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-13 12:44:22
/// Description: ROUND 函数，返回浮点参数按指定位数四舍五入的值
/// `num ROUND(num a, int digit)`
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

class FuncRoundResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'ROUND';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.length == 2) {
      var argNumber = arguments!.first;
      var argDigit = arguments[1];
      var numberValue = executor.execute(astContext, argNumber);
      var digitValue = executor.execute(astContext, argDigit);
      if (numberValue is num && digitValue is int) {
        if (numberValue is double) {
          return double.tryParse(formatNum(numberValue, digits: digitValue)) ??
              numberValue;
        } else {
          return numberValue;
        }
      } else {
        throw 'Function ROUND must have numeric arguments';
      }
    } else {
      throw 'Function ROUND invalid arguments';
    }
  }
}
