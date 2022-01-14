// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
