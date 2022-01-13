import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

///
/// Author: YoungChan
/// Date: 2022-01-13 12:10:10
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-13 12:10:11
/// Description: AVERAGE 函数，返回所有参数的平均值
/// `double AVERAGE(List<num> list)`
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

class FuncAverageResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'AVERAGE';

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
            throw 'Function AVERAGE must have a numeric list argument';
          }
        }
        return result / value.length;
      } else {
        throw 'Function AVERAGE must have a numeric list argument';
      }
    } else {
      throw 'Function AVERAGE invalid arguments';
    }
  }
}
