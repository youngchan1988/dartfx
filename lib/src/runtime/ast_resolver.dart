///
///Author: YoungChan
///Date: 2020-09-08 16:15:38
///LastEditors: YoungChan
///LastEditTime: 2020-10-13 17:00:51
///Description: file content
///Copyright: ©2020 NEW CORE Technology Co. Ltd.
///
import 'ast_runtime_node.dart';
import 'ast_context.dart';
import 'ast_runtime_executor.dart';

/// Clients may not extend, implement or mix-in this class.
abstract class AstResolver {
  ///是否匹配当前解析器
  bool canResolve(dynamic target, {String? property});

  ///解析如下表达式
  ///* target(int a, String b)
  ///* target({int a, String b})
  ///* target.property(int a, String b)
  ///* target.property({int a, String b})
  ///* target.property
  dynamic resolve(
    AstContext astContext,
    AstRuntimeExecutor executor,
    dynamic target, {
    String? property,
    List<AstRuntimeNode>? arguments,
  });
}
