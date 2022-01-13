import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

///
/// Author: YoungChan
/// Date: 2022-01-13 14:49:51
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-13 14:49:51
/// Description: ISEMPTY 函数，返回参数是否空,
/// 可以判断：
/// - String
/// - List
/// - Map
///
/// `bool ISEMPTY(dynamic a)`
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

class FuncIsEmptyResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'ISEMPTY';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.isNotEmpty == true) {
      var arg = arguments!.first;
      var value = executor.execute(astContext, arg);
      if (value is String || value is Iterable || value is Map) {
        if (value is String) {
          return value.isEmpty;
        } else if (value is Iterable) {
          return value.isEmpty;
        } else if (value is Map) {
          return value.isEmpty;
        }
      } else {
        throw 'Function ISEMPTY argument must be String or List or Map';
      }
    } else {
      throw 'Function ISEMPTY invalid arguments';
    }
  }
}
