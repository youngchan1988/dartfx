import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

///
/// Author: YoungChan
/// Date: 2022-01-13 11:36:40
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-13 11:36:40
/// Description: SUM 函数，返回参数列表内数字加和
/// `num SUM(List<num> list)`
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

class FuncSumResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'SUM';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.isNotEmpty == true) {
      var arg = arguments!.first;
      var value = executor.execute(astContext, arg);
      if (value is List) {
        num result = .0;
        for (var item in value) {
          if (item is num) {
            result += item;
          } else {
            throw 'Function SUM must have a numeric list argument';
          }
        }
        return result;
      } else {
        throw 'Function SUM must have a numeric list argument';
      }
    } else {
      throw 'Function SUM invalid arguments';
    }
  }
}
