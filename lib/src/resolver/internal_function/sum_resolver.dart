// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

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
