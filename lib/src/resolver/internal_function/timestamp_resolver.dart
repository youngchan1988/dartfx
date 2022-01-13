import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';
import 'package:intl/intl.dart';

///
/// Author: YoungChan
/// Date: 2022-01-13 14:15:54
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-13 14:15:55
/// Description: TIMESTAMP 函数，返回日期参数转换后的时间戳
/// `int TIMESTAMP(String dateString, String pattern)`
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

class FuncTimestampResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'TIMESTAMP';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.length == 2) {
      var dateArg = arguments!.first;
      var patternArg = arguments[1];
      var dateValue = executor.execute(astContext, dateArg);
      var patternValue = executor.execute(astContext, patternArg);
      if (dateValue is String && patternValue is String) {
        var format = DateFormat(patternValue);
        return format.parse(dateValue).millisecondsSinceEpoch;
      } else {
        throw 'Function TIMESTAMP must have two string arguments';
      }
    } else {
      throw 'Function TIMESTAMP invalid arguments';
    }
  }
}
