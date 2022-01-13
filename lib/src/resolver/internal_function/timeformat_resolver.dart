import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';
import 'package:intl/intl.dart';

///
/// Author: YoungChan
/// Date: 2022-01-13 15:13:52
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-13 15:13:53
/// Description: TIMEFORMAT 函数，返回时间戳参数格式化后的内容
/// `String TIMEFORMAT(int timestamp, String pattern)`
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

class FuncTimeFormatResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'TIMEFORMAT';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.length == 2) {
      var dateArg = arguments!.first;
      var patternArg = arguments[1];
      var dateValue = executor.execute(astContext, dateArg);
      var patternValue = executor.execute(astContext, patternArg);
      if (dateValue is int && patternValue is String) {
        var format = DateFormat(patternValue);
        return format.format(DateTime.fromMillisecondsSinceEpoch(dateValue));
      } else {
        throw 'Function TIMEFORMAT must have a integer argument and a String argument';
      }
    } else {
      throw 'Function TIMEFORMAT invalid arguments';
    }
  }
}
