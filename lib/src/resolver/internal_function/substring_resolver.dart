import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

///
/// Author: YoungChan
/// Date: 2022-01-13 15:43:31
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-13 15:43:32
/// Description: SUBSTRING 函数， 返回子字符串
/// `String SUBSTRING(String s, int start, [int length])`
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

class FuncSubstringResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'SUBSTRING';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if ((arguments?.length ?? 0) > 1) {
      var strArg = arguments!.first;
      var startArg = arguments[1];
      var strValue = executor.execute(astContext, strArg);
      var startValue = executor.execute(astContext, startArg);
      if (strValue is! String || startValue is! int) {
        throw 'Function SUBSTRING invalid argument type';
      }
      int end = strValue.length;
      if (arguments.length > 2) {
        var lenValue = executor.execute(astContext, arguments[2]);
        if (lenValue is int) {
          end = startValue + lenValue;
        } else {
          throw 'Function SUBSTRING invalid argument type';
        }
      }
      return strValue.substring(startValue, end);
    } else {
      throw 'Function SUBSTRING invalid arguments';
    }
  }
}
