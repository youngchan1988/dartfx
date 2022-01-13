import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

///
/// Author: YoungChan
/// Date: 2022-01-13 16:30:56
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-13 16:30:57
/// Description: REGMATCH 函数，返回正则表达式判断结果
/// `bool REGMATCH(String source, r{String reg})`
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

class FuncRegmatchResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'REGMATCH';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.length == 2) {
      var sourceArg = arguments!.first;
      var regArg = arguments[1];
      var sourceValue = executor.execute(astContext, sourceArg);
      var regValue = executor.execute(astContext, regArg);
      if (sourceValue is String && regValue is String) {
        var regExp = RegExp(regValue);
        return regExp.hasMatch(sourceValue);
      } else {
        throw 'Function REGMATCH must have two string arguments';
      }
    } else {
      throw 'Function REGMATCH invalid arguments';
    }
  }
}
