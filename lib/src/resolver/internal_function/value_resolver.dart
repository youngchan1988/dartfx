import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

///
/// Author: YoungChan
/// Date: 2022-01-13 14:05:56
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-13 14:05:56
/// Description: VALUE 函数，返回字符串参数转换的数字
/// `num VALUE(String a)`
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

class FuncValueResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'VALUE';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.isNotEmpty == true) {
      var arg = arguments!.first;
      var value = executor.execute(astContext, arg);
      if (value is String) {
        return num.tryParse(value) ?? 0;
      } else {
        throw 'Function VALUE must have a string argument';
      }
    } else {
      throw 'Function VALUE invalid arguments';
    }
  }
}
